# encoding: utf-8

class ProductsController < ApplicationController
  include Authentication
  before_action :authenticate_user, except: [:search, :get_product]

  def search
    keyword = params[:keyword].presence
    category = params[:category].presence
    top_price = params[:topPrice].to_f
    bottom_price = params[:bottomPrice].to_f
    sorting_strategy = params[:sortingStrategy]&.upcase
    sorting_direction = params[:sortingDirection]&.upcase
    current_page = params[:current].to_i > 0 ? params[:current].to_i : 1
    page_size = params[:size].to_i > 0 ? params[:size].to_i : 10

    @products = Product.search_products(
      keyword: keyword,
      category: category,
      top_price: top_price,
      bottom_price: bottom_price,
      sorting_strategy: sorting_strategy,
      sorting_direction: sorting_direction,
      current_page: current_page,
      page_size: page_size
    )

    render json: {
      results: @products.as_json(include: { product_images: { only: [:url, :file_type] } }),
      result_count: @products.total_count,
      size: @products.limit_value,
      current: @products.current_page,
      total_page: @products.total_pages
    }
  end

  def get_product
    # Get product ID from request parameters
    product_id = params[:id]

    # Query database for the product, including associated product images
    product = Product.includes(:product_images).find_by(id: product_id)

    # Return 404 error if the product is not found
    if product.nil?
      render json: { error: "Product not found" }, status: :not_found
      return
    end

    # Map product data into the expected JSON structure
    product_data = {
      id: product.id,
      payloadId: product.payload_id,
      name: product.name,
      description: product.description,
      price: product.price,
      priceId: product.price_id,
      stripeId: product.stripe_id,
      category: product.category,
      productFileUrl: product.product_file_url,
      productImages: product.product_images.map do |image|
        {
          payloadId: image.payload_id,
          url: image.url,
          filename: image.filename,
          filesize: image.filesize,
          width: image.width,
          height: image.height,
          mimeType: image.mime_type,
          fileType: image.file_type
        }
      end
    }

    # Respond with the product data in JSON format
    render json: product_data, status: :ok
  end

  # POST /api/product
  def create_product
    # Require the :product parameter and permit its keys
    product_params = params.require(:product).permit(
      :payloadId,
      :name,
      :description,
      :price,
      :priceId,
      :stripeId,
      :category,
      :approvedForSale,
      :productFileUrl,
      productImages: [
        :payloadId,
        :url,
        :filename,
        :filesize, # 确保这里是 :filesize，而不是 :fileSize
        :width,
        :height,
        :mimeType,
        :fileType
      ]
    )

    # Convert parameter keys from camelCase to snake_case
    product_params_snake_case = product_params.to_h.deep_transform_keys { |key| key.to_s.underscore }

    # Rename 'product_images' key to 'product_images_attributes' for nested attributes
    if product_params_snake_case['product_images']
      product_params_snake_case['product_images_attributes'] = product_params_snake_case.delete('product_images')
    end

    # Set 'created_by' and 'updated_by' for each product_image
    if product_params_snake_case['product_images_attributes']
      product_params_snake_case['product_images_attributes'].each do |image_params|
        image_params['created_by'] = @current_user.id.to_s
        image_params['updated_by'] = @current_user.id.to_s
      end
    end

    # Create a new product instance and associate it with the current user
    product = Product.new(product_params_snake_case)
    product.user = @current_user
    product.created_by = @current_user.id.to_s
    product.updated_by = @current_user.id.to_s

    # Save the product to the database
    if product.save
      render json: product.as_json(include: :product_images), status: :created
    else
      Rails.logger.debug "Product save failed: #{product.errors.full_messages}"
      product.product_images.each do |image|
        if image.errors.any?
          Rails.logger.debug "ProductImage errors: #{image.errors.full_messages}"
        end
      end
      render json: { errorMessage: product.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  # DELETE /api/product/:payload_id
  def delete_product
    payload_id = params[:payload_id]

    current_user = @current_user

    product = Product.find_by(payload_id: payload_id)

    if product.nil?
      render json: { errorMessage: "Product not found" }, status: :not_found
      return
    end

    product.destroy
    render json: { message: "Product deleted successfully" }, status: :no_content
  end

  # PUT /api/product
  def update_product
    product_params = params.permit(
      :payloadId,
      :name,
      :description,
      :price,
      :priceId,
      :stripeId,
      :category,
      :approvedForSale,
      :productFileUrl,
      productImages: [
        :id,
        :payloadId,
        :url,
        :filename,
        :filesize,
        :width,
        :height,
        :mimeType,
        :fileType,
        :_destroy
      ],
      product: {}
    )

    product_params.delete(:product)

    product_params_snake_case = product_params.deep_transform_keys { |key| key.to_s.underscore }

    if product_params_snake_case['product_images']
      product_params_snake_case['product_images_attributes'] = product_params_snake_case.delete('product_images')
    end

    product = Product.find_by(payload_id: product_params_snake_case['payload_id'])

    if product.nil?
      product = Product.new(product_params_snake_case)
      product.user = @current_user

      if product.save
        render json: product.as_json(include: :product_images), status: :created
      else
        render json: { errorMessage: product.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
      return
    end

    if @current_user.role == "ADMIN" || product.user_id == @current_user.id
      if product.update(product_params_snake_case)
        render json: product.as_json(include: :product_images), status: :ok
      else
        render json: { errorMessage: product.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    else
      render json: { errorMessage: "Authentication failed" }, status: :unauthorized
    end
  end

end

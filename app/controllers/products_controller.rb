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
    page_size = params[:size].to_i > 0 ? params[:size].to_i : 8

    @products = Product.search_products(
      keyword: keyword,
      category: category,
      top_price: top_price,
      bottom_price: bottom_price,
      sorting_strategy: sorting_strategy,
      sorting_direction: sorting_direction,
      current: current_page,
      size: page_size
    )

    product_fields = [
      :id,
      :payload_id,
      :name,
      :description,
      :price,
      :price_id,
      :stripe_id,
      :category,
      :product_file_url,
      :approved_for_sale,
      :created_at,
      :updated_at,
      :created_by,
      :updated_by
    ]

    product_image_fields = [
      :id,
      :payload_id,
      :url,
      :filename,
      :filesize,
      :width,
      :height,
      :mime_type,
      :file_type,
      :created_at,
      :updated_at,
      :created_by,
      :updated_by
    ]

    products_json = @products.as_json(
      only: product_fields,
      include: {
        product_images: {
          only: product_image_fields
        }
      }
    )

    products_json = products_json.map do |product|
      product.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
      if product["productImages"]
        product["productImages"].each do |image|
          image.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
        end
      end
      product
    end

    render json: {
      results: products_json,
      resultCount: @products.total_count,
      totalPage: @products.total_pages,
      current: @products.current_page,
      size: @products.limit_value
    }
  end

  def get_product
    product_id = params[:id]

    # Fetch the product without including images
    product = Product.find_by(id: product_id)

    if product.nil?
      render json: { error: "Product not found" }, status: :not_found
      return
    end

    # Filter product images where file_type == 'tablet'
    tablet_images = product.product_images.where(file_type: "tablet")

    product_fields = [
      :id,
      :payload_id,
      :name,
      :description,
      :price,
      :price_id,
      :stripe_id,
      :category,
      :product_file_url,
      :approved_for_sale,
      :created_at,
      :updated_at,
      :created_by,
      :updated_by
    ]

    product_image_fields = [
      :id,
      :payload_id,
      :url,
      :filename,
      :filesize,
      :width,
      :height,
      :mime_type,
      :file_type,
      :created_at,
      :updated_at,
      :created_by,
      :updated_by
    ]

    # Build the product JSON without images
    product_json = product.as_json(only: product_fields)

    # Add the filtered images to the product JSON
    product_json["product_images"] = tablet_images.as_json(only: product_image_fields)

    # Convert keys to camelCase
    product_json.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
    if product_json["productImages"]
      product_json["productImages"].each do |image|
        image.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
      end
    end

    render json: product_json, status: :ok
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
        :filesize,
        :width,
        :height,
        :mimeType,
        :fileType
      ]
    )

    # Convert parameter keys from camelCase to snake_case
    product_params_snake_case = product_params.to_h.deep_transform_keys { |key| key.to_s.underscore }

    # Rename 'product_images' key to 'product_images_attributes' for nested attributes
    if product_params_snake_case["product_images"]
      product_params_snake_case["product_images_attributes"] = product_params_snake_case.delete("product_images")
    end

    # Set 'created_by' and 'updated_by' for each product_image
    if product_params_snake_case["product_images_attributes"]
      product_params_snake_case["product_images_attributes"].each do |image_params|
        image_params["created_by"] = @current_user.id.to_s
        image_params["updated_by"] = @current_user.id.to_s
      end
    end

    # Create a new product instance and associate it with the current user
    product = Product.new(product_params_snake_case)
    product.user = @current_user
    product.created_by = @current_user.id.to_s
    product.updated_by = @current_user.id.to_s

    # Begin transaction
    Product.transaction do
      # Save the product to the database (temporarily without stripe_id and price_id)
      if product.save
        # Create Stripe product and price
        begin
          # Initialize Stripe API key
          Stripe.api_key = Rails.configuration.stripe[:secret_key]

          # Create Stripe product
          stripe_product = Stripe::Product.create({
                                                    name: product.name
                                                  })

          # Create Stripe price
          stripe_price = Stripe::Price.create({
                                                product: stripe_product.id,
                                                unit_amount: (product.price * 100).to_i, # Convert to cents
                                                currency: "cad"
                                              })

          # Update product with stripe_id and price_id
          product.update!(
            stripe_id: stripe_product.id,
            price_id: stripe_price.id
          )

          # Return the product with associated images
          render json: product.as_json(include: :product_images), status: :created
        rescue Stripe::StripeError => e
          Rails.logger.error "Stripe error: #{e.message}"
          # Rollback transaction
          raise ActiveRecord::Rollback
          render json: { errorMessage: "Failed to create product on Stripe: #{e.message}" }, status: :unprocessable_entity
        end
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
  end

  # DELETE /api/product/:payload_id
  def delete_product
    payload_id = params[:payload_id]

    current_user = @current_user

    product = Product.find_by(payload_id: payload_id)

    product.destroy
    render json: { message: "Product deleted successfully" }, status: :no_content
  end

  # PUT /api/product
  def update_product
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
        :filesize,
        :width,
        :height,
        :mimeType,
        :fileType
      ]
    )

    # Convert parameter keys from camelCase to snake_case
    product_params_snake_case = product_params.to_h.deep_transform_keys { |key| key.to_s.underscore }

    # Rename 'product_images' key to 'product_images_attributes' for nested attributes
    if product_params_snake_case["product_images"]
      product_params_snake_case["product_images_attributes"] = product_params_snake_case.delete("product_images")
    end

    # Find the existing product
    product = Product.find_by(payload_id: product_params_snake_case["payload_id"])

    # Check if product exists
    if product.nil?
      render json: { errorMessage: "Product not found" }, status: :not_found
      return
    end

    # Begin transaction
    Product.transaction do
      # Delete all associated product images
      product.product_images.destroy_all

      # Remove 'id's from images attributes and set 'created_by' and 'updated_by'
      if product_params_snake_case["product_images_attributes"]
        product_params_snake_case["product_images_attributes"].each do |image_params|
          image_params.delete("id") # Remove 'id' to create new images
          image_params["created_by"] = @current_user.id.to_s
          image_params["updated_by"] = @current_user.id.to_s
        end
      end

      # Set 'updated_by' for the product
      product.updated_by = @current_user.id.to_s

      # Update the product with new attributes
      if product.update(product_params_snake_case)
        render json: product.as_json(include: :product_images), status: :ok
      else
        Rails.logger.debug "Product update failed: #{product.errors.full_messages}"
        product.product_images.each do |image|
          if image.errors.any?
            Rails.logger.debug "ProductImage errors: #{image.errors.full_messages}"
          end
        end
        raise ActiveRecord::Rollback
      end
    end
  end

end

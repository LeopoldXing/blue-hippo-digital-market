# encoding: utf-8

class ProductsController < ApplicationController
  include Authentication
  before_action :authenticate_user, except: [:search, :get_product, :create_product, :update_product, :delete_product]

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
    # Permit parameters from the root level
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
    product_params_snake_case = product_params.deep_transform_keys { |key| key.to_s.underscore }

    # Rename 'product_images' key to 'product_images_attributes' for nested attributes
    if product_params_snake_case['product_images']
      product_params_snake_case['product_images_attributes'] = product_params_snake_case.delete('product_images')
    end

    # Create a new product instance and associate it with the current user
    product = Product.new(product_params_snake_case)
    product.user = @current_user

    # Save the product to the database
    if product.save
      render json: product.as_json(include: :product_images), status: :created
    else
      render json: { errorMessage: product.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  # DELETE /api/product/:payload_id
  def delete_product
    # 获取 payload_id 参数
    payload_id = params[:payload_id]

    # 1. 获取当前用户
    current_user = @current_user

    # 2. 查找要删除的产品
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
    # 从根级参数获取，并允许所有需要的参数，包括 :product 参数
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
      :product,
    )

    # 删除不必要的 :product 参数，避免干扰
    product_params.delete(:product)

    # 将参数键从驼峰命名转换为下划线命名
    product_params_snake_case = product_params.deep_transform_keys { |key| key.to_s.underscore }

    # 重命名 'product_images' 为 'product_images_attributes'，以支持嵌套属性
    if product_params_snake_case['product_images']
      product_params_snake_case['product_images_attributes'] = product_params_snake_case.delete('product_images')
    end

    # 查找原始产品
    product = Product.find_by(payload_id: product_params_snake_case['payload_id'])

    if product.nil?
      # 如果产品不存在，创建新产品
      product = Product.new(product_params_snake_case)
      product.user = @current_user

      if product.save
        render json: product.as_json(include: :product_images), status: :created
      else
        render json: { errorMessage: product.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
      return
    end

    # 检查用户权限
    if @current_user.role == "ADMIN" || product.user_id == @current_user.id
      # 更新产品
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

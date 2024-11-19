class ProductsController < ApplicationController
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

  # app/controllers/products_controller.rb
  def show
    product = Product.includes(:product_images).find_by(id: params[:id])

    if product
      render json: {
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
            payloadId: image.payload_id || nil,
            url: image.url,
            filename: image.filename || nil,
            filesize: image.filesize || nil,
            width: image.width || nil,
            height: image.height || nil,
            mimeType: image.mime_type || nil,
            fileType: image.file_type || nil
          }
        end
      }, status: :ok
    else
      render json: { success: false, error: 'Product not found' }, status: :not_found
    end
  end

end

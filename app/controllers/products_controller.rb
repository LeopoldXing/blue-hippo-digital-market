class ProductsController < ApplicationController
  def search
    # 提取参数
    keyword = params[:keyword].presence
    category = params[:category].presence
    top_price = params[:topPrice].to_f
    bottom_price = params[:bottomPrice].to_f
    sorting_strategy = params[:sortingStrategy]&.upcase
    sorting_direction = params[:sortingDirection]&.upcase
    current_page = params[:current].to_i > 0 ? params[:current].to_i : 1
    page_size = params[:size].to_i > 0 ? params[:size].to_i : 10

    # 调用模型方法获取结果
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

    # 返回结果
    render json: {
      results: @products.as_json(include: { product_images: { only: [:url, :file_type] } }),
      result_count: @products.total_count,
      size: @products.limit_value,
      current: @products.current_page,
      total_page: @products.total_pages
    }
  end
end

class Product < ApplicationRecord
  belongs_to :user
  has_many :product_images
  has_many :link_orders_products
  has_many :orders, through: :link_orders_products

  # Validations
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :payload_id, presence: true, uniqueness: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :price_id, length: { maximum: 255 }, allow_blank: true
  validates :stripe_id, length: { maximum: 255 }, allow_blank: true
  validates :category, presence: true, length: { maximum: 50 }
  validates :product_file_url, presence: true, format: { with: URI::regexp }
  validates :approved_for_sale, presence: true, inclusion: { in: %w[pending approved rejected] }
  validates :created_by, presence: true
  validates :updated_by, presence: true

  def self.search_products(params)
    products = Product.all

    # 1. Keyword search
    if params[:keyword].present?
      keyword = params[:keyword].downcase.strip
      products = products.where(
        'LOWER(name) LIKE :keyword OR LOWER(description) LIKE :keyword OR LOWER(category) LIKE :keyword',
        keyword: "%#{keyword}%"
      )
    end

    # 2. Category filter
    if params[:category].present? && params[:category].strip.downcase != 'all'
      category_value = params[:category].downcase
      products = products.where('category = :category', { category: category_value })
    end

    # 3. Price range filter
    if params[:top_price].to_f > 0
      products = products.where('price <= :top_price', { top_price: params[:top_price].to_f })
    end

    if params[:bottom_price].to_f > 0
      products = products.where('price >= :bottom_price', { bottom_price: params[:bottom_price].to_f })
    end

    # 4. Sorting
    sorting_direction = %w[ASC DESC].include?(params[:sorting_direction]) ? params[:sorting_direction] : 'DESC'
    case params[:sorting_strategy]
    when 'CREATED_TIMESTAMP'
      products = products.order("created_at #{sorting_direction}")
    when 'PRICE'
      products = products.order("price #{sorting_direction}")
    when 'POPULARITY'
      products = products.order('RANDOM()')
    else
      products = products.order("created_at DESC")
    end

    # 5. Pagination
    page = params[:current].to_i > 0 ? params[:current].to_i : 1
    per_page = params[:size].to_i > 0 ? params[:size].to_i : 10
    products.page(page).per(per_page)
  end

end

class Product < ApplicationRecord
  belongs_to :user
  has_many :product_images
  has_many :link_orders_products
  has_many :orders, through: :link_orders_products

  # Validations
  validates :name, presence: true, length: { maximum: 50 } # Name presence and length validation
  validates :price, numericality: { greater_than_or_equal_to: 0 } # Price should be non-negative
end

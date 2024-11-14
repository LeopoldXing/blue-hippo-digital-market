class Product < ApplicationRecord
  belongs_to :user
  has_many :product_images
  has_many :link_orders_products
  has_many :orders, through: :link_orders_products

  # Validations
  validates :user_id, presence: true
  validates :payload_id, presence: true, uniqueness: true
  validates :name, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_file_url, presence: true
  validates :approved_for_sale, presence: true, inclusion: { in: ['pending', 'approved', 'rejected'] }
  validates :created_by, presence: true
  validates :updated_by, presence: true
end

class Order < ApplicationRecord
  belongs_to :user
  has_many :link_orders_products
  has_many :products, through: :link_orders_products

  # Validations
  validates :payload_id, presence: true
  validates :user_id, presence: true
  validates :is_paid, allow_nil: true, inclusion: { in: [true, false] }
  validates :tax_type, presence: true, length: { maximum: 10 }
  validates :gst, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :pst, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :hst, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :created_by, presence: true
  validates :updated_by, presence: true
end

class Order < ApplicationRecord
  belongs_to :user
  has_many :link_orders_products
  has_many :products, through: :link_orders_products

  # Validations
  validates :tax_type, presence: true # Tax type presence validation
  validates :is_paid, inclusion: { in: [true, false] } # is_paid must be true or false
end

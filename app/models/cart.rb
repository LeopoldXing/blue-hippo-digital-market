class Cart < ApplicationRecord
  belongs_to :user
  belongs_to :product

  # Validations
  validates :user_id, presence: true # User ID presence validation
  validates :product_id, presence: true # Product ID presence validation
end

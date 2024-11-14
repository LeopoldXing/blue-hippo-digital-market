class Cart < ApplicationRecord
  belongs_to :user
  belongs_to :product

  # Validations
  validates :product_id, presence: true
  validates :user_id, presence: true
  validates :created_by, presence: true
  validates :updated_by, presence: true
end

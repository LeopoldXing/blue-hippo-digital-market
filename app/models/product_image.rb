class ProductImage < ApplicationRecord
  belongs_to :product

  # Validations
  validates :url, presence: true # URL presence validation
  validates :filename, presence: true, length: { maximum: 100 } # Filename presence and length validation
end

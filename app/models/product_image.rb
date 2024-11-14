class ProductImage < ApplicationRecord
  belongs_to :product

  # Validations
  validates :product_id, presence: true, numericality: { only_integer: true }
  validates :payload_id, presence: true, uniqueness: true
  validates :url, presence: true, format: { with: URI::regexp }
  validates :filename, presence: true, length: { maximum: 100 }
  validates :filesize, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :height, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :width, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :mime_type, length: { maximum: 50 }, allow_blank: true
  validates :file_type, length: { maximum: 50 }, allow_blank: true
  validates :created_by, presence: true
  validates :updated_by, presence: true
end

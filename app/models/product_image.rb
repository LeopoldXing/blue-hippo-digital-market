class ProductImage < ApplicationRecord
  belongs_to :product

  validates :product, presence: true

  validates :payload_id, presence: true, uniqueness: true
  validates :url, presence: true
  validates :filename, presence: true, length: { maximum: 100 }
  validates :filesize, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :height, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :width, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :mime_type, length: { maximum: 50 }, allow_blank: true
  validates :file_type, length: { maximum: 50 }, allow_blank: true
  validates :created_by, presence: true
  validates :updated_by, presence: true

  def as_json(options = {})
    {
      payloadId: payload_id,
      url: url,
      filename: filename,
      filesize: filesize,
      width: width,
      height: height,
      mimeType: mime_type,
      fileType: file_type
    }
  end
end

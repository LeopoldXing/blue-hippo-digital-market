class CanadaSalesTax < ApplicationRecord
  self.table_name = "canada_sales_tax"

  # Validations
  validates :province_name, presence: true, uniqueness: true
  validates :province_code, presence: true, length: { is: 2 }
  validates :gst_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :pst_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :hst_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_type, presence: true
end

class User < ApplicationRecord
  has_many :products
  has_many :orders
  has_many :carts

  # Validations
  validates :payload_id, presence: true, uniqueness: true
  validates :username, presence: true, length: { minimum: 3, maximum: 20 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :province, presence: true
  validates :address_line_1, presence: true
  validates :address_line_2, length: { maximum: 255 }, allow_blank: true
  validates :postal_code, presence: true
  validates :password_hash, presence: true
  validates :salt, presence: true
  validates :role, presence: true, inclusion: { in: %w[user admin] }
  validates :verified, inclusion: { in: [true, false] }
  validates :locked, inclusion: { in: [true, false] }
  validates :lock_until, allow_nil: true
end

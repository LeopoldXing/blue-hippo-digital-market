class User < ApplicationRecord
  has_many :products
  has_many :orders
  has_many :carts

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP } # Email format validation
  validates :username, presence: true, length: { minimum: 3, maximum: 20 } # Username length validation
end

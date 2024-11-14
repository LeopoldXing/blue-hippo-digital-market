class LinkOrdersProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product
end

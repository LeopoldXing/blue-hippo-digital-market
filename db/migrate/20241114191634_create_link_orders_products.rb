class CreateLinkOrdersProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :link_orders_products, id: :bigserial do |t|
      t.bigint :product_id, null: false
      t.bigint :order_id, null: false
      t.string :created_by
      t.string :updated_by

      t.timestamps
    end

    add_foreign_key :link_orders_products, :products
    add_foreign_key :link_orders_products, :orders
  end
end

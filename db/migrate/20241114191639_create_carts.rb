class CreateCarts < ActiveRecord::Migration[6.1]
  def change
    create_table :carts, id: :bigserial do |t|
      t.bigint :product_id, null: false
      t.bigint :user_id, null: false
      t.string :created_by, null: false
      t.string :updated_by, null: false

      t.timestamps
    end

    add_foreign_key :carts, :products
    add_foreign_key :carts, :users
  end
end

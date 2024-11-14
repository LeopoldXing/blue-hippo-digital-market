class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products, id: :bigserial do |t|
      t.bigint :user_id, null: false
      t.string :payload_id, null: false
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, default: 0.00, null: false
      t.string :price_id
      t.string :stripe_id
      t.string :category
      t.string :product_file_url, null: false
      t.string :approved_for_sale, default: 'pending', null: false
      t.string :created_by, null: false
      t.string :updated_by, null: false

      t.timestamps
    end

    add_foreign_key :products, :users
  end
end

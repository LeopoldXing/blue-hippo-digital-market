class CreateProductImages < ActiveRecord::Migration[6.1]
  def change
    create_table :product_images, id: :bigserial do |t|
      t.bigint :product_id, null: false
      t.string :payload_id, null: false
      t.string :url, null: false
      t.string :filename
      t.decimal :filesize, precision: 10, scale: 1
      t.decimal :height
      t.decimal :width
      t.string :mime_type
      t.string :file_type
      t.string :created_by, null: false
      t.string :updated_by, null: false

      t.timestamps
    end

    add_foreign_key :product_images, :products
  end
end

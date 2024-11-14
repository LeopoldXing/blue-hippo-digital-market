class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders, id: :bigserial do |t|
      t.string :payload_id
      t.bigint :user_id, null: false
      t.boolean :is_paid, default: false
      t.string :tax_type
      t.decimal :gst, precision: 5, scale: 2
      t.decimal :pst, precision: 5, scale: 2
      t.decimal :hst, precision: 5, scale: 2
      t.string :created_by
      t.string :updated_by

      t.timestamps
    end

    add_foreign_key :orders, :users
  end
end

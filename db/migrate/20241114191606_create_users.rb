class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :bigserial do |t|
      t.string :payload_id
      t.string :username
      t.string :email
      t.string :province
      t.string :address_line_1
      t.string :address_line_2
      t.string :postal_code
      t.string :password_hash
      t.string :salt
      t.string :role
      t.boolean :verified, default: false, null: false
      t.boolean :locked, default: false, null: false
      t.datetime :lock_until
      t.string :created_by, null: false
      t.string :updated_by, null: false

      t.timestamps
    end
  end
end

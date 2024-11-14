class CreateCanadaSalesTax < ActiveRecord::Migration[6.1]
  def change
    create_table :canada_sales_tax do |t|
      t.string :province_name, null: false
      t.string :province_code, limit: 2, null: false
      t.decimal :gst_rate, precision: 5, scale: 2, default: 0.00
      t.decimal :pst_rate, precision: 5, scale: 2, default: 0.00
      t.decimal :hst_rate, precision: 5, scale: 2, default: 0.00
      t.string :tax_type, null: false
    end

    add_index :canada_sales_tax, :province_code, unique: true
  end
end

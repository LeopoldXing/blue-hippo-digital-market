# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Seeding Canada Sales Tax data
CanadaSalesTax.create([
                        { province_name: 'Alberta', province_code: 'AB', gst_rate: 5.00, pst_rate: 0.00, hst_rate: 0.00, tax_type: 'GST' },
                        { province_name: 'British Columbia', province_code: 'BC', gst_rate: 5.00, pst_rate: 7.00, hst_rate: 0.00, tax_type: 'GST+PST' },
                        { province_name: 'Manitoba', province_code: 'MB', gst_rate: 5.00, pst_rate: 7.00, hst_rate: 0.00, tax_type: 'GST+PST' },
                        { province_name: 'New Brunswick', province_code: 'NB', gst_rate: 0.00, pst_rate: 0.00, hst_rate: 15.00, tax_type: 'HST' },
                        { province_name: 'Newfoundland and Labrador', province_code: 'NL', gst_rate: 0.00, pst_rate: 0.00, hst_rate: 15.00, tax_type: 'HST' },
                        { province_name: 'Northwest Territories', province_code: 'NT', gst_rate: 5.00, pst_rate: 0.00, hst_rate: 0.00, tax_type: 'GST' },
                        { province_name: 'Nova Scotia', province_code: 'NS', gst_rate: 0.00, pst_rate: 0.00, hst_rate: 15.00, tax_type: 'HST' },
                        { province_name: 'Nunavut', province_code: 'NU', gst_rate: 5.00, pst_rate: 0.00, hst_rate: 0.00, tax_type: 'GST' },
                        { province_name: 'Ontario', province_code: 'ON', gst_rate: 0.00, pst_rate: 0.00, hst_rate: 13.00, tax_type: 'HST' },
                        { province_name: 'Prince Edward Island', province_code: 'PE', gst_rate: 0.00, pst_rate: 0.00, hst_rate: 15.00, tax_type: 'HST' },
                        { province_name: 'Quebec', province_code: 'QC', gst_rate: 5.00, pst_rate: 9.975, hst_rate: 0.00, tax_type: 'GST+PST' },
                        { province_name: 'Saskatchewan', province_code: 'SK', gst_rate: 5.00, pst_rate: 6.00, hst_rate: 0.00, tax_type: 'GST+PST' },
                        { province_name: 'Yukon', province_code: 'YT', gst_rate: 5.00, pst_rate: 0.00, hst_rate: 0.00, tax_type: 'GST' }
                      ])

# Seeding Users data
User.create([
              { payload_id: 'user001', username: 'johndoe', email: 'johndoe@example.com', province: 'ON', address_line_1: '123 Main St', postal_code: 'M5V2T6', password_hash: 'hashedpassword', salt: 'salt', role: 'customer', verified: true, locked: false, created_by: 'system', updated_by: 'system' },
              { payload_id: 'user002', username: 'janedoe', email: 'janedoe@example.com', province: 'BC', address_line_1: '456 Elm St', postal_code: 'V5K0A1', password_hash: 'hashedpassword', salt: 'salt', role: 'customer', verified: true, locked: false, created_by: 'system', updated_by: 'system' }
            ])

# Seeding Products data
Product.create([
                 { user_id: 1, payload_id: 'product001', name: 'Sample Product 1', description: 'Description for product 1', price: 99.99, category: 'Electronics', product_file_url: 'http://example.com/product1', approved_for_sale: 'approved', created_by: 'system', updated_by: 'system' },
                 { user_id: 2, payload_id: 'product002', name: 'Sample Product 2', description: 'Description for product 2', price: 49.99, category: 'Books', product_file_url: 'http://example.com/product2', approved_for_sale: 'approved', created_by: 'system', updated_by: 'system' }
               ])

# Seeding Orders data
Order.create([
               { payload_id: 'order001', user_id: 1, is_paid: true, tax_type: 'HST', gst: 0.00, pst: 0.00, hst: 13.00, created_by: 'system', updated_by: 'system' },
               { payload_id: 'order002', user_id: 2, is_paid: false, tax_type: 'GST+PST', gst: 5.00, pst: 7.00, hst: 0.00, created_by: 'system', updated_by: 'system' }
             ])

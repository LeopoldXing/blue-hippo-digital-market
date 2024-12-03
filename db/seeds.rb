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

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_14_191644) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "canada_sales_tax", force: :cascade do |t|
    t.string "province_name", null: false
    t.string "province_code", limit: 2, null: false
    t.decimal "gst_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "pst_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "hst_rate", precision: 5, scale: 2, default: "0.0"
    t.string "tax_type", null: false
    t.index ["province_code"], name: "index_canada_sales_tax_on_province_code", unique: true
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "user_id", null: false
    t.string "created_by", null: false
    t.string "updated_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "link_orders_products", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "order_id", null: false
    t.string "created_by"
    t.string "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string "payload_id"
    t.bigint "user_id", null: false
    t.boolean "is_paid", default: false
    t.string "tax_type"
    t.decimal "gst", precision: 5, scale: 2
    t.decimal "pst", precision: 5, scale: 2
    t.decimal "hst", precision: 5, scale: 2
    t.string "created_by"
    t.string "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_images", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "payload_id", null: false
    t.string "url", null: false
    t.string "filename"
    t.decimal "filesize", precision: 10, scale: 1
    t.decimal "height"
    t.decimal "width"
    t.string "mime_type"
    t.string "file_type"
    t.string "created_by", null: false
    t.string "updated_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "payload_id", null: false
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.string "price_id"
    t.string "stripe_id"
    t.string "category"
    t.string "product_file_url", null: false
    t.string "approved_for_sale", default: "pending", null: false
    t.string "created_by", null: false
    t.string "updated_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "payload_id"
    t.string "username"
    t.string "email"
    t.string "province"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "postal_code"
    t.string "password_hash"
    t.string "salt"
    t.string "role"
    t.boolean "verified", default: false, null: false
    t.boolean "locked", default: false, null: false
    t.datetime "lock_until", precision: nil
    t.string "created_by", null: false
    t.string "updated_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "carts", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "link_orders_products", "orders"
  add_foreign_key "link_orders_products", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "product_images", "products"
  add_foreign_key "products", "users"
end

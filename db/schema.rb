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

ActiveRecord::Schema[8.0].define(version: 2026_02_20_181437) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "quantity"
    t.bigint "cart_id", null: false
    t.string "product_type"
    t.bigint "product_id"
    t.bigint "license_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "license_id", "product_id", "product_type"], name: "idx_on_cart_id_license_id_product_id_product_type_057ea79c24", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["license_id"], name: "index_cart_items_on_license_id"
    t.index ["product_type", "product_id"], name: "index_cart_items_on_product"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "collaborators", force: :cascade do |t|
    t.string "name", null: false
    t.string "role", null: false
    t.decimal "profit_share", precision: 5, scale: 2, default: "0.0", null: false
    t.decimal "publishing_share", precision: 5, scale: 2, default: "0.0", null: false
    t.text "notes"
    t.string "entity_type", null: false
    t.bigint "entity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_type", "entity_id"], name: "index_collaborators_on_entity"
  end

  create_table "comment_interactions", force: :cascade do |t|
    t.string "interaction_type", default: "like"
    t.bigint "comment_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comment_interactions_on_comment_id"
    t.index ["user_id"], name: "index_comment_interactions_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.string "entity_type", null: false
    t.bigint "entity_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_comments_on_discarded_at"
    t.index ["entity_type", "entity_id"], name: "index_comments_on_entity"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "free_downloads", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "track_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "customer_name", null: false
    t.index ["track_id"], name: "index_free_downloads_on_track_id"
    t.index ["user_id"], name: "index_free_downloads_on_user_id"
  end

  create_table "inbound_emails", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "subject", null: false
    t.text "message", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licenses", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "price_cents", null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.string "contract_type", null: false
    t.jsonb "contract_details", default: {}, null: false
    t.string "country"
    t.string "province"
    t.boolean "default_for_new", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_licenses_on_discarded_at"
    t.index ["title"], name: "index_licenses_on_title", unique: true
  end

  create_table "licenses_tracks", force: :cascade do |t|
    t.bigint "license_id", null: false
    t.bigint "track_id", null: false
    t.index ["license_id", "track_id"], name: "index_licenses_tracks_on_license_id_and_track_id", unique: true
    t.index ["license_id"], name: "index_licenses_tracks_on_license_id"
    t.index ["track_id"], name: "index_licenses_tracks_on_track_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.boolean "is_immutable", default: false, null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "order_id", null: false
    t.integer "unit_price_cents", null: false
    t.string "currency", null: false
    t.string "product_type", null: false
    t.jsonb "product_snapshot", default: {}, null: false
    t.jsonb "license_snapshot", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "public_id", null: false
    t.bigint "user_id", null: false
    t.integer "subtotal_cents", default: 0, null: false
    t.string "currency", default: "usd", null: false
    t.string "status", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "samples", force: :cascade do |t|
    t.string "name", null: false
    t.string "artist", default: ""
    t.string "link", default: ""
    t.bigint "track_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "index_samples_on_track_id"
  end

  create_table "track_hearts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "track_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "index_track_hearts_on_track_id"
    t.index ["user_id", "track_id"], name: "index_track_hearts_on_user_id_and_track_id"
    t.index ["user_id"], name: "index_track_hearts_on_user_id"
  end

  create_table "track_plays", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "track_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "index_track_plays_on_track_id"
    t.index ["user_id"], name: "index_track_plays_on_user_id"
  end

  create_table "track_recommendations", force: :cascade do |t|
    t.string "group", null: false
    t.string "tag_names", default: [], array: true
    t.boolean "disabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group"], name: "index_track_recommendations_on_group", unique: true
  end

  create_table "track_tags", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "track_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id", "name"], name: "index_track_tags_on_track_id_and_name", unique: true
    t.index ["track_id"], name: "index_track_tags_on_track_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "title", null: false
    t.string "key"
    t.integer "bpm"
    t.boolean "is_public", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "genre"
    t.text "description"
    t.datetime "discarded_at"
    t.string "slug"
    t.index ["discarded_at"], name: "index_tracks_on_discarded_at"
    t.index ["slug"], name: "index_tracks_on_slug", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.string "status", null: false
    t.string "stripe_charge_id"
    t.string "stripe_receipt_url"
    t.string "customer_email"
    t.string "customer_name"
    t.integer "amount_cents", null: false
    t.string "currency", null: false
    t.bigint "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_transactions_on_order_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.integer "role", default: 0, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name", default: "", null: false
    t.string "provider"
    t.string "uid"
    t.text "biography", default: "", null: false
    t.datetime "discarded_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "licenses"
  add_foreign_key "carts", "users"
  add_foreign_key "comment_interactions", "comments"
  add_foreign_key "comment_interactions", "users", on_delete: :nullify
  add_foreign_key "comments", "users"
  add_foreign_key "free_downloads", "tracks", on_delete: :nullify
  add_foreign_key "free_downloads", "users", on_delete: :nullify
  add_foreign_key "licenses_tracks", "licenses"
  add_foreign_key "licenses_tracks", "tracks"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "users"
  add_foreign_key "samples", "tracks"
  add_foreign_key "track_hearts", "tracks", on_delete: :nullify
  add_foreign_key "track_hearts", "users", on_delete: :nullify
  add_foreign_key "track_plays", "tracks", on_delete: :nullify
  add_foreign_key "track_plays", "users", on_delete: :nullify
  add_foreign_key "track_tags", "tracks"
end

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

ActiveRecord::Schema[8.0].define(version: 2025_08_15_034925) do
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
    t.index ["entity_type", "entity_id"], name: "index_comments_on_entity"
    t.index ["user_id"], name: "index_comments_on_user_id"
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
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comment_interactions", "comments"
  add_foreign_key "comment_interactions", "users", on_delete: :nullify
  add_foreign_key "comments", "users"
  add_foreign_key "samples", "tracks"
  add_foreign_key "track_hearts", "tracks", on_delete: :nullify
  add_foreign_key "track_hearts", "users", on_delete: :nullify
  add_foreign_key "track_plays", "tracks", on_delete: :nullify
  add_foreign_key "track_plays", "users", on_delete: :nullify
  add_foreign_key "track_tags", "tracks"
end

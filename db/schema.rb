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

ActiveRecord::Schema[8.0].define(version: 2025_06_17_205124) do
  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "ancestry", null: false, collation: "BINARY"
    t.index ["ancestry"], name: "index_categories_on_ancestry"
  end

  create_table "email_subscribers", force: :cascade do |t|
    t.string "email", null: false
    t.boolean "confirmed", default: false
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_email_subscribers_on_email", unique: true
  end

  create_table "github_app_settings", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.datetime "updated_at"
    t.index ["key"], name: "index_github_app_settings_on_key", unique: true
  end

  create_table "locales", force: :cascade do |t|
    t.string "key", null: false
    t.string "english_name", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["english_name"], name: "index_locales_on_english_name", unique: true
    t.index ["name"], name: "index_locales_on_name", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.string "id2"
    t.integer "category_id", null: false
    t.string "permalink", null: false
    t.text "title"
    t.text "content"
    t.datetime "published_at", null: false
    t.datetime "updated_at"
    t.text "filename"
    t.string "thumbnail"
    t.index ["category_id"], name: "index_posts_on_category_id"
    t.index ["id2"], name: "index_posts_on_id2", unique: true
  end

  create_table "resumes", force: :cascade do |t|
    t.string "title", null: false
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "phone_number"
    t.string "position"
    t.string "city"
    t.string "summary"
    t.date "birth_date"
    t.integer "height"
    t.integer "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.datetime "updated_at"
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "social_media_accounts", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.datetime "updated_at"
    t.index ["key"], name: "index_social_media_accounts_on_key", unique: true
  end

  create_table "technical_skills", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "themes", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "enabled", default: true, null: false
    t.boolean "free", default: true, null: false
    t.integer "color", default: 1, null: false
  end

  create_table "translations", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "locale_id", null: false
    t.text "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale_id"], name: "index_translations_on_locale_id"
    t.index ["post_id"], name: "index_translations_on_post_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "posts", "categories"
  add_foreign_key "sessions", "users"
  add_foreign_key "translations", "locales"
  add_foreign_key "translations", "posts"
end

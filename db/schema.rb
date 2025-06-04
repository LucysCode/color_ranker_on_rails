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

ActiveRecord::Schema[8.0].define(version: 2025_06_03_033551) do
  create_table "color_pair_votes", force: :cascade do |t|
    t.string "left_color"
    t.string "right_color"
    t.boolean "is_ugly"
    t.boolean "is_nice"
    t.string "session_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "color_pair"
    t.integer "user_id"
    t.string "vote_type"
    t.index ["user_id"], name: "index_color_pair_votes_on_user_id"
  end

  create_table "color_votes", force: :cascade do |t|
    t.string "hex_color"
    t.boolean "is_ugly"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_nice"
    t.string "session_id"
    t.integer "position"
    t.string "left_color"
    t.string "right_color"
    t.integer "user_id"
    t.string "vote_type"
    t.index ["user_id"], name: "index_color_votes_on_user_id"
  end

  create_table "pair_votes", force: :cascade do |t|
    t.string "color1"
    t.string "color2"
    t.string "vote_type"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_pair_votes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "color", null: false
    t.string "vote_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "color_pair_votes", "users"
  add_foreign_key "color_votes", "users"
  add_foreign_key "pair_votes", "users"
  add_foreign_key "votes", "users"
end

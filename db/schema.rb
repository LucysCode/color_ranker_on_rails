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

ActiveRecord::Schema[8.0].define(version: 2025_05_25_054301) do
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
  end
end

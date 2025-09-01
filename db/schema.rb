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

ActiveRecord::Schema[7.1].define(version: 2025_09_01_204013) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ad_hoc_todos", force: :cascade do |t|
    t.text "description", null: false
    t.bigint "user_id", null: false
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_ad_hoc_todos_on_user_id"
  end

  create_table "goal_completions", force: :cascade do |t|
    t.bigint "goal_id", null: false
    t.date "week_start_date"
    t.integer "completed_count"
    t.integer "week_number"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["goal_id"], name: "index_goal_completions_on_goal_id"
  end

  create_table "goals", force: :cascade do |t|
    t.string "description", null: false
    t.integer "target_count", default: 1, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.index ["user_id", "description"], name: "index_goals_on_user_id_and_description", unique: true
    t.index ["user_id"], name: "index_goals_on_user_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "user_id", null: false
    t.string "notable_type", null: false
    t.bigint "notable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notable_type", "notable_id"], name: "index_notes_on_notable"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "recurring_meetings", force: :cascade do |t|
    t.string "name", null: false
    t.string "person", null: false
    t.integer "frequency", default: 0, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "week_of_month", default: 1
    t.integer "month_of_quarter", default: 1
    t.string "biweekly_pattern", default: "first_third"
    t.index ["user_id", "name"], name: "index_recurring_meetings_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_recurring_meetings_on_user_id"
  end

  create_table "todo_items", force: :cascade do |t|
    t.text "description", null: false
    t.bigint "user_id", null: false
    t.string "source_type", null: false
    t.integer "source_id", null: false
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "week_start_date", null: false
    t.index ["user_id"], name: "index_todo_items_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "ad_hoc_todos", "users"
  add_foreign_key "goal_completions", "goals"
  add_foreign_key "goals", "users"
  add_foreign_key "notes", "users"
  add_foreign_key "recurring_meetings", "users"
  add_foreign_key "todo_items", "users"
end

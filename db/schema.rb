# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150816103859) do

  create_table "bids", force: :cascade do |t|
    t.integer  "mechanic_id"
    t.integer  "markup_price"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
  end

  create_table "order_types", force: :cascade do |t|
    t.string "name"
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "mechanic_id"
    t.string   "address"
    t.datetime "appointment"
    t.integer  "order_type_id"
    t.integer  "brand_id"
    t.integer  "series_id"
    t.integer  "quoted_price"
    t.integer  "price"
    t.text     "remark"
    t.integer  "professionality"
    t.integer  "timeliness"
    t.text     "review"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "series", force: :cascade do |t|
    t.string "name"
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "nickname"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "mobile"
    t.string   "persistence_token"
    t.string   "verification_code"
    t.boolean  "mobile_confirmed",  default: false
    t.string   "nickname"
    t.integer  "gender_cd"
    t.string   "address"
    t.boolean  "is_mechanic"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "users", ["mobile"], name: "index_users_on_mobile", unique: true

end

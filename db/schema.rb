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

ActiveRecord::Schema.define(version: 20160501034915) do

  create_table "bids", force: :cascade do |t|
    t.integer  "mechanic_id"
    t.integer  "order_id"
    t.integer  "markup_price", default: 0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "bids", ["mechanic_id"], name: "index_bids_on_mechanic_id"
  add_index "bids", ["order_id"], name: "index_bids_on_order_id"

  create_table "brands", force: :cascade do |t|
    t.string "name"
  end

  create_table "cities", force: :cascade do |t|
    t.string  "name"
    t.string  "fullname"
    t.integer "province_id"
    t.integer "lbs_id"
  end

  add_index "cities", ["fullname"], name: "index_cities_on_fullname"
  add_index "cities", ["lbs_id"], name: "index_cities_on_lbs_id"
  add_index "cities", ["province_id"], name: "index_cities_on_province_id"

  create_table "districts", force: :cascade do |t|
    t.string  "name"
    t.string  "fullname"
    t.integer "city_id"
    t.integer "lbs_id"
  end

  add_index "districts", ["city_id"], name: "index_districts_on_city_id"
  add_index "districts", ["fullname"], name: "index_districts_on_fullname"
  add_index "districts", ["lbs_id"], name: "index_districts_on_lbs_id"

  create_table "fellowships", force: :cascade do |t|
    t.integer  "mechanic_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "remark"
  end

  add_index "fellowships", ["mechanic_id"], name: "index_fellowships_on_mechanic_id"
  add_index "fellowships", ["user_id"], name: "index_fellowships_on_user_id"

  create_table "mechanics", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "province_cd"
    t.integer  "city_cd"
    t.integer  "district_cd"
    t.text     "description"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.float    "professionality_average",                          default: 4.0
    t.float    "timeliness_average",                               default: 4.0
    t.decimal  "total_income",            precision: 10, scale: 2, default: 0.0
    t.integer  "available_orders_count",                           default: 0
    t.string   "user_nickname"
    t.string   "user_mobile"
    t.string   "user_address"
    t.integer  "revoke_orders_count"
    t.string   "user_weixin_openid"
  end

  add_index "mechanics", ["city_cd"], name: "index_mechanics_on_city_cd"
  add_index "mechanics", ["district_cd"], name: "index_mechanics_on_district_cd"
  add_index "mechanics", ["province_cd"], name: "index_mechanics_on_province_cd"
  add_index "mechanics", ["user_id"], name: "index_mechanics_on_user_id"

  create_table "mechanics_skills", id: false, force: :cascade do |t|
    t.integer "mechanic_id", null: false
    t.integer "skill_id",    null: false
  end

  create_table "merchants", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "mobile"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "verification_code"
    t.boolean  "confirmed",           default: false
    t.string   "nickname"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "role_cd",             default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "active",              default: true
    t.integer  "login_count",         default: 0,     null: false
    t.integer  "failed_login_count",  default: 0,     null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "user_nickname"
    t.string   "user_mobile"
    t.string   "user_address"
  end

  add_index "merchants", ["mobile"], name: "index_merchants_on_mobile", unique: true
  add_index "merchants", ["role_cd"], name: "index_merchants_on_role_cd"
  add_index "merchants", ["user_id"], name: "index_merchants_on_user_id"

  create_table "metrics", force: :cascade do |t|
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "user_id"
    t.string   "method"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metrics", ["source_type", "source_id"], name: "index_metrics_on_source_type_and_source_id"
  add_index "metrics", ["user_id"], name: "index_metrics_on_user_id"

  create_table "notes", force: :cascade do |t|
    t.integer  "store_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["store_id"], name: "index_notes_on_store_id"

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "mechanic_id"
    t.integer  "merchant_id"
    t.string   "address"
    t.datetime "appointment"
    t.integer  "skill_cd"
    t.integer  "brand_cd"
    t.integer  "series_cd"
    t.integer  "quoted_price"
    t.text     "remark"
    t.integer  "professionality",                default: 4
    t.integer  "timeliness",                     default: 4
    t.text     "review"
    t.integer  "state_cd",                       default: 0
    t.integer  "mechanic_sent_count",            default: 0
    t.integer  "bid_id"
    t.integer  "lbs_id"
    t.string   "mechanic_attach_1_file_name"
    t.string   "mechanic_attach_1_content_type"
    t.integer  "mechanic_attach_1_file_size"
    t.datetime "mechanic_attach_1_updated_at"
    t.string   "mechanic_attach_2_file_name"
    t.string   "mechanic_attach_2_content_type"
    t.integer  "mechanic_attach_2_file_size"
    t.datetime "mechanic_attach_2_updated_at"
    t.string   "user_attach_1_file_name"
    t.string   "user_attach_1_content_type"
    t.integer  "user_attach_1_file_size"
    t.datetime "user_attach_1_updated_at"
    t.string   "user_attach_2_file_name"
    t.string   "user_attach_2_content_type"
    t.integer  "user_attach_2_file_size"
    t.datetime "user_attach_2_updated_at"
    t.string   "contact_nickname"
    t.string   "contact_mobile"
    t.integer  "cancel_cd",                      default: 0
    t.datetime "start_working_at"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "markup_price",                   default: 0
    t.integer  "pay_type_cd",                    default: 0
    t.datetime "paid_at"
    t.datetime "refunded_at"
    t.string   "trade_no"
    t.integer  "refund_cd",                      default: 0
    t.integer  "province_cd"
    t.integer  "city_cd"
    t.string   "user_nickname"
    t.string   "user_mobile"
    t.string   "mechanic_nickname"
    t.string   "mechanic_mobile"
    t.string   "merchant_nickname"
    t.string   "merchant_mobile"
    t.datetime "reviewed_at"
    t.datetime "finish_working_at"
    t.text     "merchant_remark"
    t.datetime "closed_at"
    t.boolean  "hosting",                        default: false
    t.integer  "procedure_price",                default: 0
  end

  add_index "orders", ["bid_id"], name: "index_orders_on_bid_id"
  add_index "orders", ["cancel_cd"], name: "index_orders_on_cancel_cd"
  add_index "orders", ["hosting"], name: "index_orders_on_hosting"
  add_index "orders", ["mechanic_id"], name: "index_orders_on_mechanic_id"
  add_index "orders", ["merchant_id"], name: "index_orders_on_merchant_id"
  add_index "orders", ["pay_type_cd"], name: "index_orders_on_pay_type_cd"
  add_index "orders", ["refund_cd"], name: "index_orders_on_refund_cd"
  add_index "orders", ["state_cd"], name: "index_orders_on_state_cd"
  add_index "orders", ["user_id"], name: "index_orders_on_user_id"

  create_table "provinces", force: :cascade do |t|
    t.string  "name"
    t.string  "fullname"
    t.integer "lbs_id"
  end

  add_index "provinces", ["fullname"], name: "index_provinces_on_fullname"
  add_index "provinces", ["lbs_id"], name: "index_provinces_on_lbs_id"

  create_table "series", force: :cascade do |t|
    t.string  "name"
    t.integer "brand_id"
  end

  add_index "series", ["brand_id"], name: "index_series_on_brand_id"

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true

  create_table "skills", force: :cascade do |t|
    t.string "name"
  end

  create_table "user_groups", force: :cascade do |t|
    t.string   "nickname"
    t.text     "description"
    t.boolean  "confirmed",                                      default: false
    t.integer  "user_id"
    t.string   "weixin_qr_code_ticket"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.decimal  "total_commission",      precision: 10, scale: 2, default: 0.0
    t.integer  "settled_orders_count",                           default: 0
    t.integer  "users_count",                                    default: 0
  end

  add_index "user_groups", ["user_id"], name: "index_user_groups_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "mobile"
    t.string   "persistence_token"
    t.string   "verification_code"
    t.boolean  "active",                                          default: true
    t.boolean  "confirmed",                                       default: false
    t.string   "weixin_openid"
    t.string   "nickname"
    t.integer  "gender_cd"
    t.string   "address"
    t.string   "qq"
    t.float    "balance",                                         default: 0.0
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "role_cd",                                         default: 0
    t.integer  "user_group_id"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.integer  "login_count",                                     default: 0,     null: false
    t.integer  "failed_login_count",                              default: 0,     null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.decimal  "total_cost",             precision: 10, scale: 2, default: 0.0
    t.integer  "available_orders_count",                          default: 0
    t.boolean  "host",                                            default: false
    t.boolean  "hidden",                                          default: false
  end

  add_index "users", ["host"], name: "index_users_on_host"
  add_index "users", ["mobile"], name: "index_users_on_mobile", unique: true
  add_index "users", ["role_cd"], name: "index_users_on_role_cd"
  add_index "users", ["user_group_id"], name: "index_users_on_user_group_id"

  create_table "withdrawals", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "amount"
    t.integer  "state_cd",   default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "paid_at"
  end

  add_index "withdrawals", ["state_cd"], name: "index_withdrawals_on_state_cd"
  add_index "withdrawals", ["user_id"], name: "index_withdrawals_on_user_id"

end

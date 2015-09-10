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

ActiveRecord::Schema.define(version: 20150908082640) do

  create_table "actions", force: :cascade do |t|
    t.string   "name",       limit: 45
    t.string   "image",      limit: 512
    t.integer  "price",      limit: 8
    t.integer  "max_vote",   limit: 4
    t.float    "discount",   limit: 24
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "bct_images", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.string   "image",          limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "bct_images", ["broadcaster_id"], name: "index_bct_images_on_broadcaster_id", using: :btree

  create_table "bct_types", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "slug",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "bct_videos", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.string   "video",          limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "bct_videos", ["broadcaster_id"], name: "index_bct_videos_on_broadcaster_id", using: :btree

  create_table "broadcaster_levels", force: :cascade do |t|
    t.integer  "level",      limit: 4
    t.integer  "min_heart",  limit: 8
    t.integer  "grade",      limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "broadcasters", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.integer  "bct_type_id",          limit: 4
    t.integer  "broadcaster_level_id", limit: 4
    t.string   "fullname",             limit: 255
    t.string   "fb_link",              limit: 2048
    t.string   "twitter_link",         limit: 2048
    t.string   "instagram_link",       limit: 2048
    t.text     "description",          limit: 65535
    t.integer  "broadcaster_exp",      limit: 4
    t.integer  "recived_heart",        limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "broadcasters", ["bct_type_id"], name: "index_broadcasters_on_bct_type_id", using: :btree
  add_index "broadcasters", ["broadcaster_level_id"], name: "index_broadcasters_on_broadcaster_level_id", using: :btree
  add_index "broadcasters", ["user_id"], name: "index_broadcasters_on_user_id", using: :btree

  create_table "gifts", force: :cascade do |t|
    t.string   "name",       limit: 45
    t.string   "image",      limit: 45
    t.integer  "price",      limit: 4
    t.float    "discount",   limit: 24
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "room_types", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "slug",        limit: 45
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "room_type_id",   limit: 4
    t.string   "title",          limit: 255
    t.string   "slug",           limit: 255
    t.string   "thumb",          limit: 512
    t.string   "background",     limit: 512
    t.boolean  "is_privated"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "rooms", ["broadcaster_id"], name: "index_rooms_on_broadcaster_id", using: :btree
  add_index "rooms", ["room_type_id"], name: "index_rooms_on_room_type_id", using: :btree

  create_table "user_follow_bcts", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "broadcaster_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "user_follow_bcts", ["broadcaster_id"], name: "index_user_follow_bcts_on_broadcaster_id", using: :btree
  add_index "user_follow_bcts", ["user_id"], name: "index_user_follow_bcts_on_user_id", using: :btree

  create_table "user_has_vip_packages", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "vip_package_id", limit: 4
    t.boolean  "actived"
    t.datetime "active_date"
    t.datetime "expiry_date"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "user_has_vip_packages", ["user_id"], name: "index_user_has_vip_packages_on_user_id", using: :btree
  add_index "user_has_vip_packages", ["vip_package_id"], name: "index_user_has_vip_packages_on_vip_package_id", using: :btree

  create_table "user_levels", force: :cascade do |t|
    t.integer  "level",         limit: 4
    t.integer  "min_exp",       limit: 8
    t.integer  "heart_per_day", limit: 4
    t.integer  "grade",         limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",           limit: 255
    t.string   "password_digest", limit: 255
    t.string   "username",        limit: 255
    t.string   "name",            limit: 255
    t.date     "birthday"
    t.string   "gender",          limit: 5
    t.string   "address",         limit: 512
    t.string   "phone",           limit: 45
    t.string   "fb_id",           limit: 128
    t.string   "gp_id",           limit: 128
    t.string   "avatar",          limit: 512
    t.string   "cover",           limit: 512
    t.integer  "money",           limit: 4
    t.integer  "user_exp",        limit: 4
    t.string   "active_code",     limit: 10
    t.boolean  "actived"
    t.datetime "active_date"
    t.boolean  "is_broadcaster"
    t.integer  "no_heart",        limit: 4
    t.boolean  "is_banned"
    t.string   "token",           limit: 255
    t.datetime "last_login"
    t.integer  "user_level_id",   limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "users", ["user_level_id"], name: "index_users_on_user_level_id", using: :btree

  create_table "vip_packages", force: :cascade do |t|
    t.integer  "vip_id",     limit: 4
    t.string   "name",       limit: 45
    t.string   "code",       limit: 45
    t.string   "no_day",     limit: 45
    t.integer  "price",      limit: 8
    t.float    "discount",   limit: 24
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "vip_packages", ["vip_id"], name: "index_vip_packages_on_vip_id", using: :btree

  create_table "vips", force: :cascade do |t|
    t.string   "name",               limit: 45
    t.string   "code",               limit: 45
    t.string   "image",              limit: 512
    t.integer  "weight",             limit: 4
    t.integer  "no_char",            limit: 4
    t.integer  "screen_text_time",   limit: 4
    t.string   "screen_text_effect", limit: 45
    t.integer  "kick_level",         limit: 4
    t.integer  "clock_kick",         limit: 4
    t.boolean  "clock_ads"
    t.float    "exp_bonus",          limit: 24
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_foreign_key "bct_images", "broadcasters"
  add_foreign_key "bct_videos", "broadcasters"
  add_foreign_key "broadcasters", "bct_types"
  add_foreign_key "broadcasters", "broadcaster_levels"
  add_foreign_key "broadcasters", "users"
  add_foreign_key "rooms", "broadcasters"
  add_foreign_key "rooms", "room_types"
  add_foreign_key "user_follow_bcts", "broadcasters"
  add_foreign_key "user_follow_bcts", "users"
  add_foreign_key "user_has_vip_packages", "users"
  add_foreign_key "user_has_vip_packages", "vip_packages"
  add_foreign_key "users", "user_levels"
  add_foreign_key "vip_packages", "vips"
end

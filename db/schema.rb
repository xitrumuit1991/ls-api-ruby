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

ActiveRecord::Schema.define(version: 20161125051617) do

  create_table "acls", force: :cascade do |t|
    t.integer  "role_id",     limit: 4
    t.integer  "resource_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "acls", ["resource_id"], name: "index_acls_on_resource_id", using: :btree
  add_index "acls", ["role_id"], name: "index_acls_on_role_id", using: :btree

  create_table "action_logs", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "room_id",        limit: 4
    t.integer  "room_action_id", limit: 4
    t.float    "cost",           limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "action_logs", ["room_action_id"], name: "index_action_logs_on_room_action_id", using: :btree
  add_index "action_logs", ["room_id"], name: "index_action_logs_on_room_id", using: :btree
  add_index "action_logs", ["user_id"], name: "index_action_logs_on_user_id", using: :btree

  create_table "admins", force: :cascade do |t|
    t.integer  "role_id",                limit: 4
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
  add_index "admins", ["role_id"], name: "index_admins_on_role_id", using: :btree

  create_table "android_receipts", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.string   "orderId",       limit: 255
    t.string   "packageName",   limit: 255
    t.string   "productId",     limit: 255
    t.integer  "purchaseTime",  limit: 8
    t.integer  "purchaseState", limit: 4
    t.string   "purchaseToken", limit: 255
    t.boolean  "status",                    default: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "android_receipts", ["user_id"], name: "index_android_receipts_on_user_id", using: :btree

  create_table "ban_users", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "room_id",    limit: 4
    t.integer  "days",       limit: 4
    t.string   "note",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "ban_users", ["room_id"], name: "index_ban_users_on_room_id", using: :btree
  add_index "ban_users", ["user_id"], name: "index_ban_users_on_user_id", using: :btree

  create_table "banks", force: :cascade do |t|
    t.string   "bankID",     limit: 255
    t.string   "name",       limit: 255
    t.boolean  "status"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "bct_actions", force: :cascade do |t|
    t.integer  "room_id",        limit: 4
    t.integer  "room_action_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "bct_actions", ["room_action_id"], name: "index_bct_actions_on_room_action_id", using: :btree
  add_index "bct_actions", ["room_id"], name: "index_bct_actions_on_room_id", using: :btree

  create_table "bct_gifts", force: :cascade do |t|
    t.integer  "room_id",    limit: 4
    t.integer  "gift_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "bct_gifts", ["gift_id"], name: "index_bct_gifts_on_gift_id", using: :btree
  add_index "bct_gifts", ["room_id"], name: "index_bct_gifts_on_room_id", using: :btree

  create_table "bct_images", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.string   "image",          limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "bct_images", ["broadcaster_id"], name: "index_bct_images_on_broadcaster_id", using: :btree

  create_table "bct_time_logs", force: :cascade do |t|
    t.integer  "room_id",    limit: 4
    t.datetime "last_login"
    t.datetime "start_room"
    t.datetime "end_room"
    t.boolean  "status",               default: true
    t.boolean  "flag",                 default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "bct_time_logs", ["room_id"], name: "index_bct_time_logs_on_room_id", using: :btree

  create_table "bct_types", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "slug",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "bct_videos", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.string   "title",          limit: 255
    t.string   "video_type",     limit: 50
    t.string   "video",          limit: 255
    t.string   "thumb",          limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "bct_videos", ["broadcaster_id"], name: "index_bct_videos_on_broadcaster_id", using: :btree

  create_table "broadcaster_backgrounds", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.string   "image",          limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "broadcaster_backgrounds", ["broadcaster_id"], name: "index_broadcaster_backgrounds_on_broadcaster_id", using: :btree

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
    t.text     "description",          limit: 65535
    t.integer  "broadcaster_exp",      limit: 4,     default: 0
    t.integer  "recived_heart",        limit: 4,     default: 0
    t.boolean  "deleted",                            default: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "broadcasters", ["bct_type_id"], name: "index_broadcasters_on_bct_type_id", using: :btree
  add_index "broadcasters", ["broadcaster_level_id"], name: "index_broadcasters_on_broadcaster_level_id", using: :btree
  add_index "broadcasters", ["user_id"], name: "index_broadcasters_on_user_id", using: :btree

  create_table "cards", force: :cascade do |t|
    t.integer  "price",      limit: 4
    t.integer  "coin",       limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "cart_logs", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "provider_id", limit: 4
    t.string   "pin",         limit: 255
    t.string   "serial",      limit: 255
    t.integer  "price",       limit: 4
    t.integer  "coin",        limit: 4
    t.integer  "status",      limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "cart_logs", ["provider_id"], name: "index_cart_logs_on_provider_id", using: :btree
  add_index "cart_logs", ["user_id"], name: "index_cart_logs_on_user_id", using: :btree

  create_table "coins", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "code",          limit: 255
    t.float    "price",         limit: 24,  default: 0.0
    t.float    "price_usd",     limit: 24,  default: 0.0
    t.integer  "quantity",      limit: 4,   default: 0
    t.integer  "bonus_coins",   limit: 4,   default: 0
    t.float    "bonus_percent", limit: 24,  default: 0.0
    t.string   "image",         limit: 255
    t.string   "app",           limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "device_tokens", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.string   "device_id",    limit: 255
    t.string   "device_token", limit: 255
    t.string   "device_type",  limit: 20
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "device_tokens", ["user_id"], name: "index_device_tokens_on_user_id", using: :btree

  create_table "email_domain_blacklists", id: false, force: :cascade do |t|
    t.string "domain", limit: 100
  end

  create_table "fb_share_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "room_id",    limit: 4
    t.string   "fb_id",      limit: 100
    t.string   "post_id",    limit: 255
    t.string   "coin",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "fb_share_logs", ["room_id"], name: "index_fb_share_logs_on_room_id", using: :btree
  add_index "fb_share_logs", ["user_id"], name: "index_fb_share_logs_on_user_id", using: :btree

  create_table "featureds", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "weight",         limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "featureds", ["broadcaster_id"], name: "index_featureds_on_broadcaster_id", using: :btree

  create_table "gift_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "room_id",    limit: 4
    t.integer  "gift_id",    limit: 4
    t.integer  "quantity",   limit: 4
    t.float    "cost",       limit: 24
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "gift_logs", ["gift_id"], name: "index_gift_logs_on_gift_id", using: :btree
  add_index "gift_logs", ["room_id"], name: "index_gift_logs_on_room_id", using: :btree
  add_index "gift_logs", ["user_id"], name: "index_gift_logs_on_user_id", using: :btree

  create_table "gifts", force: :cascade do |t|
    t.string   "name",       limit: 45
    t.string   "image",      limit: 45
    t.integer  "price",      limit: 4
    t.float    "discount",   limit: 24
    t.boolean  "status",                default: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "heart_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "room_id",    limit: 4
    t.integer  "quantity",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "heart_logs", ["room_id"], name: "index_heart_logs_on_room_id", using: :btree
  add_index "heart_logs", ["user_id"], name: "index_heart_logs_on_user_id", using: :btree

  create_table "home_featureds", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "weight",         limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "home_featureds", ["broadcaster_id"], name: "index_home_featureds_on_broadcaster_id", using: :btree

  create_table "ios_receipts", force: :cascade do |t|
    t.integer  "user_id",                    limit: 4
    t.integer  "quantity",                   limit: 4
    t.string   "product_id",                 limit: 255
    t.string   "transaction_id",             limit: 255
    t.string   "original_transaction_id",    limit: 255
    t.string   "purchase_date",              limit: 255
    t.string   "purchase_date_ms",           limit: 255
    t.string   "purchase_date_pst",          limit: 255
    t.string   "original_purchase_date",     limit: 255
    t.string   "original_purchase_date_ms",  limit: 255
    t.string   "original_purchase_date_pst", limit: 255
    t.string   "is_trial_period",            limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "ios_receipts", ["user_id"], name: "index_ios_receipts_on_user_id", using: :btree

  create_table "lounge_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "room_id",    limit: 4
    t.integer  "lounge",     limit: 4
    t.float    "cost",       limit: 24
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "lounge_logs", ["room_id"], name: "index_lounge_logs_on_room_id", using: :btree
  add_index "lounge_logs", ["user_id"], name: "index_lounge_logs_on_user_id", using: :btree

  create_table "mbuy_requests", force: :cascade do |t|
    t.string   "command",      limit: 255
    t.string   "cp_code",      limit: 255
    t.string   "content_code", limit: 255
    t.string   "total_amount", limit: 255
    t.string   "account",      limit: 255
    t.string   "isdn",         limit: 255
    t.string   "result",       limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "megabank_logs", force: :cascade do |t|
    t.integer  "bank_id",       limit: 4
    t.integer  "megabank_id",   limit: 4
    t.integer  "user_id",       limit: 4
    t.string   "transid",       limit: 255
    t.string   "mac",           limit: 255
    t.text     "descriptionvn", limit: 65535
    t.text     "descriptionen", limit: 65535
    t.string   "responsecode",  limit: 255
    t.string   "status",        limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "megabank_logs", ["bank_id"], name: "index_megabank_logs_on_bank_id", using: :btree
  add_index "megabank_logs", ["megabank_id"], name: "index_megabank_logs_on_megabank_id", using: :btree
  add_index "megabank_logs", ["user_id"], name: "index_megabank_logs_on_user_id", using: :btree

  create_table "megabanks", force: :cascade do |t|
    t.integer  "price",      limit: 4
    t.integer  "coin",       limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "mobifone_blacklists", id: false, force: :cascade do |t|
    t.string "sub_id", limit: 20
  end

  create_table "mobifone_ips", primary_key: "ip", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mobifone_user_money_logs", force: :cascade do |t|
    t.integer  "mobifone_user_id", limit: 4
    t.string   "money",            limit: 255
    t.string   "info",             limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "mobifone_user_money_logs", ["mobifone_user_id"], name: "index_mobifone_user_money_logs_on_mobifone_user_id", using: :btree

  create_table "mobifone_user_vip_logs", force: :cascade do |t|
    t.integer  "mobifone_user_id",        limit: 4
    t.integer  "user_has_vip_package_id", limit: 4
    t.string   "pkg_code",                limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "mobifone_user_vip_logs", ["mobifone_user_id"], name: "index_mobifone_user_vip_logs_on_mobifone_user_id", using: :btree
  add_index "mobifone_user_vip_logs", ["user_has_vip_package_id"], name: "index_mobifone_user_vip_logs_on_user_has_vip_package_id", using: :btree

  create_table "mobifone_users", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.string   "sub_id",           limit: 255, null: false
    t.string   "pkg_code",         limit: 255
    t.string   "register_channel", limit: 255
    t.datetime "active_date"
    t.datetime "expiry_date"
    t.boolean  "status"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "mobifone_users", ["sub_id"], name: "index_mobifone_users_on_sub_id", unique: true, using: :btree
  add_index "mobifone_users", ["user_id"], name: "index_mobifone_users_on_user_id", using: :btree

  create_table "monthly_top_bct_level_ups", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "times",          limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "monthly_top_bct_level_ups", ["broadcaster_id"], name: "index_monthly_top_bct_level_ups_on_broadcaster_id", using: :btree

  create_table "monthly_top_bct_received_gifts", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "quantity",       limit: 4
    t.float    "money",          limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "monthly_top_bct_received_gifts", ["broadcaster_id"], name: "index_monthly_top_bct_received_gifts_on_broadcaster_id", using: :btree

  create_table "monthly_top_bct_received_hearts", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "quantity",       limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "monthly_top_bct_received_hearts", ["broadcaster_id"], name: "index_monthly_top_bct_received_hearts_on_broadcaster_id", using: :btree

  create_table "monthly_top_user_level_ups", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "times",      limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "monthly_top_user_level_ups", ["user_id"], name: "index_monthly_top_user_level_ups_on_user_id", using: :btree

  create_table "monthly_top_user_send_gifts", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "room_id",        limit: 4
    t.integer  "quantity",       limit: 4
    t.float    "money",          limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "broadcaster_id", limit: 4
  end

  add_index "monthly_top_user_send_gifts", ["broadcaster_id"], name: "index_monthly_top_user_send_gifts_on_broadcaster_id", using: :btree
  add_index "monthly_top_user_send_gifts", ["room_id"], name: "index_monthly_top_user_send_gifts_on_room_id", using: :btree
  add_index "monthly_top_user_send_gifts", ["user_id"], name: "index_monthly_top_user_send_gifts_on_user_id", using: :btree

  create_table "otps", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "code",       limit: 255
    t.string   "service",    limit: 255
    t.boolean  "used",                   default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "otps", ["user_id"], name: "index_otps_on_user_id", using: :btree

  create_table "posters", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "sub_title",  limit: 255
    t.string   "thumb",      limit: 255
    t.string   "link",       limit: 255
    t.integer  "weight",     limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "providers", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "slug",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.string   "class_name",  limit: 255
    t.string   "action_name", limit: 255
    t.string   "can",         limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "code",        limit: 255
    t.string   "description", limit: 255
    t.integer  "weight",      limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "room_actions", force: :cascade do |t|
    t.string   "name",       limit: 45
    t.string   "image",      limit: 512
    t.integer  "price",      limit: 8
    t.integer  "max_vote",   limit: 4
    t.float    "discount",   limit: 24
    t.boolean  "status",                 default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "room_backgrounds", force: :cascade do |t|
    t.string   "image",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "room_featureds", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "weight",         limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "room_featureds", ["broadcaster_id"], name: "index_room_featureds_on_broadcaster_id", using: :btree

  create_table "room_types", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "slug",        limit: 45
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.integer  "broadcaster_id",            limit: 4
    t.integer  "room_type_id",              limit: 4
    t.integer  "broadcaster_background_id", limit: 4
    t.integer  "room_background_id",        limit: 4
    t.string   "title",                     limit: 255
    t.string   "slug",                      limit: 255
    t.string   "thumb",                     limit: 512
    t.string   "thumb_crop",                limit: 255
    t.string   "thumb_poster",              limit: 255
    t.boolean  "on_air",                                default: false
    t.boolean  "is_privated"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  add_index "rooms", ["broadcaster_background_id"], name: "index_rooms_on_broadcaster_background_id", using: :btree
  add_index "rooms", ["broadcaster_id"], name: "index_rooms_on_broadcaster_id", using: :btree
  add_index "rooms", ["room_background_id"], name: "index_rooms_on_room_background_id", using: :btree
  add_index "rooms", ["room_type_id"], name: "index_rooms_on_room_type_id", using: :btree

  create_table "schedules", force: :cascade do |t|
    t.datetime "start"
    t.datetime "end"
    t.integer  "room_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "schedules", ["room_id"], name: "index_schedules_on_room_id", using: :btree

  create_table "screen_text_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "room_id",    limit: 4
    t.text     "content",    limit: 65535
    t.float    "cost",       limit: 24
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "screen_text_logs", ["room_id"], name: "index_screen_text_logs_on_room_id", using: :btree
  add_index "screen_text_logs", ["user_id"], name: "index_screen_text_logs_on_user_id", using: :btree

  create_table "send_money_logs", force: :cascade do |t|
    t.string   "from",       limit: 255
    t.integer  "user_id",    limit: 4
    t.integer  "money",      limit: 4
    t.string   "note",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "send_money_logs", ["user_id"], name: "index_send_money_logs_on_user_id", using: :btree

  create_table "slides", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.string   "description",     limit: 255
    t.string   "sub_description", limit: 255
    t.datetime "start_time"
    t.integer  "weight",          limit: 4
    t.string   "link",            limit: 255
    t.string   "banner",          limit: 255
    t.string   "thumb",           limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "sms_logs", force: :cascade do |t|
    t.string   "active_code", limit: 255
    t.string   "moid",        limit: 255
    t.string   "phone",       limit: 255
    t.string   "shortcode",   limit: 255
    t.string   "keyword",     limit: 255
    t.text     "content",     limit: 65535
    t.string   "trans_date",  limit: 255
    t.string   "checksum",    limit: 255
    t.integer  "amount",      limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "sms_mobiles", force: :cascade do |t|
    t.integer  "price",      limit: 4
    t.integer  "coin",       limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.text     "content",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "statuses", ["user_id"], name: "index_statuses_on_user_id", using: :btree

  create_table "tmp_users", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.string   "exp",        limit: 255
    t.text     "token",      limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "top_bct_level_ups", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "times",          limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "top_bct_level_ups", ["broadcaster_id"], name: "index_top_bct_level_ups_on_broadcaster_id", using: :btree

  create_table "top_bct_received_gifts", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "quantity",       limit: 4
    t.float    "money",          limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "top_bct_received_gifts", ["broadcaster_id"], name: "index_top_bct_received_gifts_on_broadcaster_id", using: :btree

  create_table "top_bct_received_hearts", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "quantity",       limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "top_bct_received_hearts", ["broadcaster_id"], name: "index_top_bct_received_hearts_on_broadcaster_id", using: :btree

  create_table "top_user_level_ups", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "times",      limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "top_user_level_ups", ["user_id"], name: "index_top_user_level_ups_on_user_id", using: :btree

  create_table "top_user_send_gifts", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "room_id",        limit: 4
    t.integer  "quantity",       limit: 4
    t.float    "money",          limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "broadcaster_id", limit: 4
  end

  add_index "top_user_send_gifts", ["broadcaster_id"], name: "index_top_user_send_gifts_on_broadcaster_id", using: :btree
  add_index "top_user_send_gifts", ["room_id"], name: "index_top_user_send_gifts_on_room_id", using: :btree
  add_index "top_user_send_gifts", ["user_id"], name: "index_top_user_send_gifts_on_user_id", using: :btree

  create_table "trade_logs", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "vip_package_id", limit: 4
    t.boolean  "status"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "trade_logs", ["user_id"], name: "index_trade_logs_on_user_id", using: :btree
  add_index "trade_logs", ["vip_package_id"], name: "index_trade_logs_on_vip_package_id", using: :btree

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

  create_table "user_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "room_id",    limit: 4
    t.float    "money",      limit: 24
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "user_logs", ["room_id"], name: "index_user_logs_on_room_id", using: :btree
  add_index "user_logs", ["user_id"], name: "index_user_logs_on_user_id", using: :btree

  create_table "user_received_hearts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "hearts",     limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_received_hearts", ["user_id"], name: "index_user_received_hearts_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",           limit: 255
    t.string   "password_digest", limit: 255
    t.string   "username",        limit: 255
    t.string   "name",            limit: 255
    t.date     "birthday"
    t.string   "address",         limit: 512
    t.string   "phone",           limit: 45
    t.string   "fb_id",           limit: 128
    t.string   "gp_id",           limit: 128
    t.string   "avatar",          limit: 512
    t.string   "avatar_crop",     limit: 255
    t.string   "cover",           limit: 512
    t.string   "cover_crop",      limit: 255
    t.string   "facebook_link",   limit: 255
    t.string   "twitter_link",    limit: 255
    t.string   "instagram_link",  limit: 255
    t.integer  "money",           limit: 4,   default: 0
    t.integer  "user_exp",        limit: 4,   default: 0
    t.string   "active_code",     limit: 10
    t.boolean  "actived",                     default: false
    t.datetime "active_date"
    t.boolean  "is_broadcaster",              default: false
    t.integer  "no_heart",        limit: 4,   default: 0
    t.boolean  "is_banned",                   default: false
    t.string   "token",           limit: 255
    t.datetime "last_login"
    t.integer  "user_level_id",   limit: 4
    t.boolean  "deleted",                     default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "gender",          limit: 6
    t.string   "forgot_code",     limit: 255
    t.integer  "failed_attempts", limit: 4,   default: 0
    t.datetime "failed_at"
    t.datetime "locked_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["phone"], name: "index_users_on_phone", unique: true, using: :btree
  add_index "users", ["user_level_id"], name: "index_users_on_user_level_id", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

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

  create_table "wap_mbf_logs", force: :cascade do |t|
    t.string   "msisdn",      limit: 255
    t.integer  "sp_id",       limit: 4
    t.string   "trans_id",    limit: 255
    t.string   "pkg",         limit: 255
    t.integer  "price",       limit: 4
    t.text     "information", limit: 65535
    t.boolean  "status"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "weekly_top_bct_level_ups", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "times",          limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "weekly_top_bct_level_ups", ["broadcaster_id"], name: "index_weekly_top_bct_level_ups_on_broadcaster_id", using: :btree

  create_table "weekly_top_bct_received_gifts", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "quantity",       limit: 4
    t.float    "money",          limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "weekly_top_bct_received_gifts", ["broadcaster_id"], name: "index_weekly_top_bct_received_gifts_on_broadcaster_id", using: :btree

  create_table "weekly_top_bct_received_hearts", force: :cascade do |t|
    t.integer  "broadcaster_id", limit: 4
    t.integer  "quantity",       limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "weekly_top_bct_received_hearts", ["broadcaster_id"], name: "index_weekly_top_bct_received_hearts_on_broadcaster_id", using: :btree

  create_table "weekly_top_user_level_ups", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "times",      limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "weekly_top_user_level_ups", ["user_id"], name: "index_weekly_top_user_level_ups_on_user_id", using: :btree

  create_table "weekly_top_user_send_gifts", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "room_id",        limit: 4
    t.integer  "quantity",       limit: 4
    t.float    "money",          limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "broadcaster_id", limit: 4
  end

  add_index "weekly_top_user_send_gifts", ["broadcaster_id"], name: "index_weekly_top_user_send_gifts_on_broadcaster_id", using: :btree
  add_index "weekly_top_user_send_gifts", ["room_id"], name: "index_weekly_top_user_send_gifts_on_room_id", using: :btree
  add_index "weekly_top_user_send_gifts", ["user_id"], name: "index_weekly_top_user_send_gifts_on_user_id", using: :btree

  add_foreign_key "acls", "resources"
  add_foreign_key "acls", "roles"
  add_foreign_key "action_logs", "room_actions"
  add_foreign_key "action_logs", "rooms"
  add_foreign_key "action_logs", "users"
  add_foreign_key "admins", "roles"
  add_foreign_key "android_receipts", "users"
  add_foreign_key "ban_users", "rooms"
  add_foreign_key "ban_users", "users"
  add_foreign_key "bct_actions", "room_actions"
  add_foreign_key "bct_actions", "rooms"
  add_foreign_key "bct_gifts", "gifts"
  add_foreign_key "bct_gifts", "rooms"
  add_foreign_key "bct_images", "broadcasters"
  add_foreign_key "bct_time_logs", "rooms"
  add_foreign_key "bct_videos", "broadcasters"
  add_foreign_key "broadcaster_backgrounds", "broadcasters"
  add_foreign_key "broadcasters", "bct_types"
  add_foreign_key "broadcasters", "broadcaster_levels"
  add_foreign_key "broadcasters", "users"
  add_foreign_key "cart_logs", "providers"
  add_foreign_key "cart_logs", "users"
  add_foreign_key "device_tokens", "users"
  add_foreign_key "fb_share_logs", "rooms"
  add_foreign_key "fb_share_logs", "users"
  add_foreign_key "featureds", "broadcasters"
  add_foreign_key "gift_logs", "gifts"
  add_foreign_key "gift_logs", "rooms"
  add_foreign_key "gift_logs", "users"
  add_foreign_key "heart_logs", "rooms"
  add_foreign_key "heart_logs", "users"
  add_foreign_key "home_featureds", "broadcasters"
  add_foreign_key "ios_receipts", "users"
  add_foreign_key "lounge_logs", "rooms"
  add_foreign_key "lounge_logs", "users"
  add_foreign_key "megabank_logs", "banks"
  add_foreign_key "megabank_logs", "megabanks"
  add_foreign_key "megabank_logs", "users"
  add_foreign_key "mobifone_user_money_logs", "mobifone_users"
  add_foreign_key "mobifone_user_vip_logs", "mobifone_users"
  add_foreign_key "mobifone_user_vip_logs", "user_has_vip_packages"
  add_foreign_key "mobifone_users", "users"
  add_foreign_key "monthly_top_bct_level_ups", "broadcasters"
  add_foreign_key "monthly_top_bct_received_gifts", "broadcasters"
  add_foreign_key "monthly_top_bct_received_hearts", "broadcasters"
  add_foreign_key "monthly_top_user_level_ups", "users"
  add_foreign_key "monthly_top_user_send_gifts", "broadcasters"
  add_foreign_key "monthly_top_user_send_gifts", "rooms"
  add_foreign_key "monthly_top_user_send_gifts", "users"
  add_foreign_key "otps", "users"
  add_foreign_key "room_featureds", "broadcasters"
  add_foreign_key "rooms", "broadcaster_backgrounds"
  add_foreign_key "rooms", "broadcasters"
  add_foreign_key "rooms", "room_backgrounds"
  add_foreign_key "rooms", "room_types"
  add_foreign_key "schedules", "rooms"
  add_foreign_key "screen_text_logs", "rooms"
  add_foreign_key "screen_text_logs", "users"
  add_foreign_key "send_money_logs", "users"
  add_foreign_key "statuses", "users"
  add_foreign_key "top_bct_level_ups", "broadcasters"
  add_foreign_key "top_bct_received_gifts", "broadcasters"
  add_foreign_key "top_bct_received_hearts", "broadcasters"
  add_foreign_key "top_user_level_ups", "users"
  add_foreign_key "top_user_send_gifts", "broadcasters"
  add_foreign_key "top_user_send_gifts", "rooms"
  add_foreign_key "top_user_send_gifts", "users"
  add_foreign_key "trade_logs", "users"
  add_foreign_key "trade_logs", "vip_packages"
  add_foreign_key "user_follow_bcts", "broadcasters"
  add_foreign_key "user_follow_bcts", "users"
  add_foreign_key "user_has_vip_packages", "users"
  add_foreign_key "user_has_vip_packages", "vip_packages"
  add_foreign_key "user_logs", "rooms"
  add_foreign_key "user_logs", "users"
  add_foreign_key "user_received_hearts", "users"
  add_foreign_key "users", "user_levels"
  add_foreign_key "vip_packages", "vips"
  add_foreign_key "weekly_top_bct_level_ups", "broadcasters"
  add_foreign_key "weekly_top_bct_received_gifts", "broadcasters"
  add_foreign_key "weekly_top_bct_received_hearts", "broadcasters"
  add_foreign_key "weekly_top_user_level_ups", "users"
  add_foreign_key "weekly_top_user_send_gifts", "broadcasters"
  add_foreign_key "weekly_top_user_send_gifts", "rooms"
  add_foreign_key "weekly_top_user_send_gifts", "users"
end

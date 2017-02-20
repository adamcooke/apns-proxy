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

ActiveRecord::Schema.define(version: 20170220122006) do

  create_table "applications", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "api_key",    limit: 255
  end

  create_table "auth_keys", force: :cascade do |t|
    t.integer  "application_id", limit: 4
    t.string   "name",           limit: 255
    t.string   "key",            limit: 255
    t.integer  "environment_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_keys", ["application_id"], name: "index_auth_keys_on_application_id", using: :btree
  add_index "auth_keys", ["environment_id"], name: "index_auth_keys_on_environment_id", using: :btree

  create_table "devices", force: :cascade do |t|
    t.integer  "auth_key_id",               limit: 4
    t.string   "token",                     limit: 255
    t.integer  "usage",                     limit: 4,   default: 0
    t.datetime "last_sent_notification_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at"
    t.datetime "last_registered_at"
    t.string   "label",                     limit: 255
  end

  add_index "devices", ["auth_key_id"], name: "index_devices_on_auth_key_id", using: :btree

  create_table "environments", force: :cascade do |t|
    t.integer  "application_id",   limit: 4
    t.string   "name",             limit: 255
    t.text     "certificate",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "apns_environment", limit: 255
    t.string   "topic",            limit: 255
  end

  add_index "environments", ["application_id"], name: "index_environments_on_application_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "auth_key_id",       limit: 4
    t.integer  "device_id",         limit: 4
    t.datetime "pushed_at"
    t.datetime "created_at"
    t.string   "alert_body",        limit: 255
    t.string   "action_loc_key",    limit: 255
    t.string   "loc_key",           limit: 255
    t.text     "loc_args",          limit: 65535
    t.string   "launch_image",      limit: 255
    t.integer  "badge",             limit: 4
    t.string   "sound",             limit: 255
    t.boolean  "content_available"
    t.text     "custom_data",       limit: 65535
    t.integer  "error_code",        limit: 4
    t.boolean  "locked",                          default: false
    t.string   "status_code",       limit: 255
    t.string   "status_reason",     limit: 255
  end

  add_index "notifications", ["auth_key_id"], name: "index_notifications_on_auth_key_id", using: :btree
  add_index "notifications", ["device_id"], name: "index_notifications_on_device_id", using: :btree
  add_index "notifications", ["pushed_at"], name: "index_notifications_on_pushed_at", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 255
    t.string   "password_digest", limit: 255
    t.string   "name",            limit: 255
    t.string   "email_address",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

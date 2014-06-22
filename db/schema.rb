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

ActiveRecord::Schema.define(version: 20140622171237) do

  create_table "applications", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auth_keys", force: true do |t|
    t.integer  "application_id"
    t.string   "name"
    t.string   "key"
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_keys", ["application_id"], name: "index_auth_keys_on_application_id", using: :btree
  add_index "auth_keys", ["environment_id"], name: "index_auth_keys_on_environment_id", using: :btree

  create_table "devices", force: true do |t|
    t.integer  "auth_key_id"
    t.string   "token"
    t.integer  "usage",           default: 0
    t.datetime "last_used_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at"
  end

  add_index "devices", ["auth_key_id"], name: "index_devices_on_auth_key_id", using: :btree

  create_table "environments", force: true do |t|
    t.integer  "application_id"
    t.string   "name"
    t.text     "certificate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "environments", ["application_id"], name: "index_environments_on_application_id", using: :btree

  create_table "notifications", force: true do |t|
    t.integer  "auth_key_id"
    t.integer  "device_id"
    t.datetime "pushed_at"
    t.datetime "created_at"
    t.string   "alert_body"
    t.string   "action_loc_key"
    t.string   "loc_key"
    t.text     "loc_args"
    t.string   "launch_image"
    t.integer  "badge"
    t.string   "sound"
    t.boolean  "content_available"
    t.text     "custom_data"
    t.integer  "error_code"
  end

  add_index "notifications", ["auth_key_id"], name: "index_notifications_on_auth_key_id", using: :btree
  add_index "notifications", ["device_id"], name: "index_notifications_on_device_id", using: :btree
  add_index "notifications", ["pushed_at"], name: "index_notifications_on_pushed_at", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "password_digest"
    t.string   "name"
    t.string   "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

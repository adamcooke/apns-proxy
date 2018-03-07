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

ActiveRecord::Schema.define(version: 20180307123300) do

  create_table "applications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "api_key"
  end

  create_table "auth_keys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "application_id"
    t.string "name"
    t.string "key"
    t.integer "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["application_id"], name: "index_auth_keys_on_application_id"
    t.index ["environment_id"], name: "index_auth_keys_on_environment_id"
  end

  create_table "authie_sessions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "token"
    t.string "browser_id"
    t.integer "user_id"
    t.boolean "active", default: true
    t.text "data"
    t.datetime "expires_at"
    t.datetime "login_at"
    t.string "login_ip"
    t.datetime "last_activity_at"
    t.string "last_activity_ip"
    t.string "last_activity_path"
    t.string "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "user_type"
    t.integer "parent_id"
    t.datetime "two_factored_at"
    t.string "two_factored_ip"
    t.integer "requests", default: 0
    t.datetime "password_seen_at"
    t.string "token_hash"
    t.string "host"
    t.index ["browser_id"], name: "index_authie_sessions_on_browser_id", length: { browser_id: 10 }
    t.index ["token"], name: "index_authie_sessions_on_token", length: { token: 10 }
    t.index ["token_hash"], name: "index_authie_sessions_on_token_hash", length: { token_hash: 10 }
    t.index ["user_id"], name: "index_authie_sessions_on_user_id"
  end

  create_table "devices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "auth_key_id"
    t.string "token"
    t.integer "usage", default: 0
    t.datetime "last_sent_notification_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at"
    t.datetime "last_registered_at"
    t.string "label"
    t.index ["auth_key_id"], name: "index_devices_on_auth_key_id"
  end

  create_table "environments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "application_id"
    t.string "name"
    t.text "certificate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "apns_environment"
    t.string "topic"
    t.index ["application_id"], name: "index_environments_on_application_id"
  end

  create_table "login_events", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "user_type"
    t.integer "user_id"
    t.string "username"
    t.string "action"
    t.string "interface"
    t.string "ip"
    t.string "user_agent"
    t.datetime "created_at"
    t.index ["created_at"], name: "index_login_events_on_created_at"
    t.index ["interface"], name: "index_login_events_on_interface", length: { interface: 10 }
    t.index ["ip"], name: "index_login_events_on_ip", length: { ip: 10 }
    t.index ["user_type", "user_id"], name: "index_login_events_on_user_type_and_user_id", length: { user_type: 10 }
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "auth_key_id"
    t.integer "device_id"
    t.datetime "pushed_at"
    t.datetime "created_at"
    t.string "alert_body"
    t.string "action_loc_key"
    t.string "loc_key"
    t.text "loc_args"
    t.string "launch_image"
    t.integer "badge"
    t.string "sound"
    t.boolean "content_available"
    t.text "custom_data"
    t.integer "error_code"
    t.boolean "locked", default: false
    t.string "status_code"
    t.string "status_reason"
    t.index ["auth_key_id"], name: "index_notifications_on_auth_key_id"
    t.index ["device_id"], name: "index_notifications_on_device_id"
    t.index ["pushed_at"], name: "index_notifications_on_pushed_at"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "username"
    t.string "password_digest"
    t.string "name"
    t.string "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

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

ActiveRecord::Schema.define(version: 20161201014007) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "locations", force: :cascade do |t|
    t.string   "yelp_id"
    t.string   "center"
    t.integer  "attending",  default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["center"], name: "index_locations_on_center", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.string   "plans",                default: [],                 array: true
    t.string   "password_reset_token"
    t.boolean  "confirmed",            default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", using: :btree
  end

end

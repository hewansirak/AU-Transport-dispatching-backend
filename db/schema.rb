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

ActiveRecord::Schema[7.2].define(version: 2026_03_17_094255) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.bigint "transport_request_id", null: false
    t.bigint "driver_id", null: false
    t.bigint "vehicle_id", null: false
    t.bigint "dispatcher_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispatcher_id"], name: "index_assignments_on_dispatcher_id"
    t.index ["driver_id"], name: "index_assignments_on_driver_id"
    t.index ["transport_request_id"], name: "index_assignments_on_transport_request_id"
    t.index ["vehicle_id"], name: "index_assignments_on_vehicle_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
  end

  create_table "drivers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "license_number", null: false
    t.date "license_expiry"
    t.string "phone_number", null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["license_number"], name: "index_drivers_on_license_number", unique: true
    t.index ["user_id"], name: "index_drivers_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "transport_request_id", null: false
    t.bigint "recipient_id", null: false
    t.integer "channel", default: 0, null: false
    t.integer "notification_type", null: false
    t.datetime "sent_at"
    t.integer "status", default: 0, null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["transport_request_id"], name: "index_notifications_on_transport_request_id"
  end

  create_table "transport_requests", force: :cascade do |t|
    t.bigint "requester_id", null: false
    t.string "originator_office", null: false
    t.bigint "department_id", null: false
    t.string "telephone_extension"
    t.date "required_date", null: false
    t.time "required_from_time", null: false
    t.time "required_to_time", null: false
    t.boolean "working_hours", default: true, null: false
    t.string "destination", null: false
    t.text "purpose", null: false
    t.integer "service_type", default: 0, null: false
    t.integer "passenger_count"
    t.integer "status", default: 0, null: false
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.text "rejection_reason"
    t.bigint "assigned_by_id"
    t.datetime "assigned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_transport_requests_on_assigned_by_id"
    t.index ["department_id"], name: "index_transport_requests_on_department_id"
    t.index ["requester_id"], name: "index_transport_requests_on_requester_id"
    t.index ["reviewed_by_id"], name: "index_transport_requests_on_reviewed_by_id"
  end

  create_table "trip_status_updates", force: :cascade do |t|
    t.bigint "transport_request_id", null: false
    t.bigint "driver_id", null: false
    t.integer "status", null: false
    t.text "note"
    t.string "location_note"
    t.datetime "reported_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_trip_status_updates_on_driver_id"
    t.index ["transport_request_id"], name: "index_trip_status_updates_on_transport_request_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "telephone_extension"
    t.integer "role", default: 0, null: false
    t.bigint "department_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "plate_number", null: false
    t.string "make", null: false
    t.string "model", null: false
    t.integer "year"
    t.integer "vehicle_type", default: 0, null: false
    t.integer "capacity"
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plate_number"], name: "index_vehicles_on_plate_number", unique: true
  end

  add_foreign_key "assignments", "drivers"
  add_foreign_key "assignments", "transport_requests"
  add_foreign_key "assignments", "users", column: "dispatcher_id"
  add_foreign_key "assignments", "vehicles"
  add_foreign_key "drivers", "users"
  add_foreign_key "notifications", "transport_requests"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "transport_requests", "departments"
  add_foreign_key "transport_requests", "users", column: "assigned_by_id"
  add_foreign_key "transport_requests", "users", column: "requester_id"
  add_foreign_key "transport_requests", "users", column: "reviewed_by_id"
  add_foreign_key "trip_status_updates", "drivers"
  add_foreign_key "trip_status_updates", "transport_requests"
  add_foreign_key "users", "departments"
end

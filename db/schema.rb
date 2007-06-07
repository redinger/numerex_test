# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 1) do

  create_table "devices", :force => true do |t|
    t.column "name",               :string,   :limit => 75
    t.column "imei",               :string,   :limit => 30
    t.column "phone_number",       :string,   :limit => 20
    t.column "recent_location_id", :integer
    t.column "created_at",         :datetime
    t.column "updated_at",         :datetime
  end

  create_table "devices_users", :force => true do |t|
    t.column "device_id", :integer
    t.column "user_id",   :integer
  end

  create_table "geofences", :force => true do |t|
    t.column "name",       :string,   :limit => 30
    t.column "perimeter",  :string
    t.column "type",       :integer,  :limit => 4
    t.column "device_id",  :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "readings", :force => true do |t|
    t.column "latitude",   :float
    t.column "longitude",  :float
    t.column "altitude",   :float
    t.column "speed",      :float
    t.column "direction",  :float
    t.column "device_id",  :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.column "login",                     :string
    t.column "email",                     :string
    t.column "crypted_password",          :string,   :limit => 40
    t.column "salt",                      :string,   :limit => 40
    t.column "created_at",                :datetime
    t.column "updated_at",                :datetime
    t.column "remember_token",            :string
    t.column "remember_token_expires_at", :datetime
  end

end

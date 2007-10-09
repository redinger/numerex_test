class CreateInitialSchema < ActiveRecord::Migration
  def self.up
    create_table "accounts", :force => true do |t|
      t.column "company",     :string,   :limit => 75
      t.column "address",     :string,   :limit => 50
      t.column "city",        :string,   :limit => 50
      t.column "state",       :string,   :limit => 25
      t.column "zip",         :string,   :limit => 15
      t.column "subdomain",   :string,   :limit => 100
      t.column "updated_at",  :datetime
      t.column "created_at",  :datetime
      t.column "is_verified", :boolean,                 :default => false
    end

    create_table "devices", :force => true do |t|
      t.column "name",                :string,   :limit => 75
      t.column "imei",                :string,   :limit => 30
      t.column "phone_number",        :string,   :limit => 20
      t.column "recent_reading_id",   :integer,                :default => 0
      t.column "ip_address",          :string
      t.column "created_at",          :datetime
      t.column "updated_at",          :datetime
      t.column "provision_status_id", :integer,  :limit => 2,  :default => 0
      t.column "account_id",          :integer,                :default => 0
      t.column "last_online_time",    :datetime
      t.column "modem_id",            :string,   :limit => 30
      t.column "online_threshold",    :integer
    end

    create_table "geofences", :force => true do |t|
      t.column "name",       :string,   :limit => 30
      t.column "bounds",     :string
      t.column "is_radial",  :boolean,                :default => true
      t.column "device_id",  :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "address",    :string
      t.column "fence_num",  :integer
    end

    create_table "notifications", :force => true do |t|
      t.column "user_id",           :integer
      t.column "device_id",         :integer
      t.column "created_at",        :datetime
      t.column "notification_type", :string,   :limit => 25
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
      t.column "event_type", :string,   :limit => 25, :default => "DEFAULT"
      t.column "note",       :string
      t.column "address",    :text
      t.column "notified",   :boolean,                :default => false
    end

    create_table "sessions", :force => true do |t|
      t.column "session_id", :string
      t.column "data",       :text
      t.column "updated_at", :datetime
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

    create_table "users", :force => true do |t|
      t.column "first_name",                :string,   :limit => 30
      t.column "last_name",                 :string,   :limit => 30
      t.column "email",                     :string
      t.column "crypted_password",          :string,   :limit => 40
      t.column "salt",                      :string,   :limit => 40
      t.column "created_at",                :datetime
      t.column "updated_at",                :datetime
      t.column "remember_token",            :string
      t.column "remember_token_expires_at", :datetime
      t.column "account_id",                :integer
      t.column "is_master",                 :boolean,                :default => false
      t.column "is_admin",                  :boolean,                :default => false
      t.column "last_login_dt",             :datetime
      t.column "enotify",                   :boolean,                :default => false
      t.column "time_zone",                 :string
    end
end
  
  def self.down
     drop_table :accounts
     drop_table :devices
     drop_table :geofences
     drop_table :notifications
     drop_table :readings
     drop_table :sessions
     drop_table :users
  end
end
  
  
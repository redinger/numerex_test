class CreateInitialSchema < ActiveRecord::Migration
  def self.up
=begin
    create_table "accounts", :force => true do |t|
      t.column "name",           :string,   :limit => 50
      t.column "master_user_id", :integer
      t.column "created_at",     :datetime
    end

    create_table "customers", :force => true do |t|
      t.column "name",    :string, :limit => 200
      t.column "address", :string, :limit => 100
      t.column "created_at",     :datetime
    end
=end

    create_table "users", :force => true do |t|
      t.column "login",                     :string
      t.column "email",                     :string
      t.column "crypted_password",          :string, :limit => 40
      t.column "salt",                      :string, :limit => 40
      t.column "created_at",                :datetime
      t.column "updated_at",                :datetime
      t.column "remember_token",            :string
      t.column "remember_token_expires_at", :datetime
    end
    
    create_table "devices", :force => true do |t|
      t.column "name",         :string,   :limit => 75
      t.column "imei",         :string,   :limit => 30
      t.column "phone_number", :string,   :limit => 20
      t.column "recent_location_id", :integer
      t.column "created_at",  :datetime
      t.column "updated_at",  :datetime
    end
    
    create_table "devices_users", :force => true do |t|
      t.column "device_id", :integer
      t.column "user_id", :integer
    end

    create_table "geofences", :force => true do |t|
      t.column "name",      :string,  :limit => 30
      t.column "perimeter", :string
      t.column "type",      :integer, :limit => 4
      t.column "device_id", :integer
      t.column "created_at",     :datetime
      t.column "updated_at",  :datetime
    end

=begin
    create_table "locations", :force => true do |t|
      t.column "latitude",      :float
      t.column "longitude",     :float
      t.column "altitude",      :integer
      t.column "device_id",     :integer
      t.column "street_number", :string,  :limit => 15
      t.column "street_name",   :string,  :limit => 75
      t.column "city",          :string,  :limit => 50
      t.column "state",         :string,  :limit => 20
      t.column "zip",           :string,  :limit => 20
      t.column "dt",            :string,  :limit => 100
      t.column "is_alarm",      :boolean,                :default => false
      t.column "created_at",     :datetime
      t.column "updated_at",  :datetime
    end
=end

# Needs support for IO, but we'll save that for later
    create_table "readings", :force => true do |t|
      t.column "latitude",      :float
      t.column "longitude",     :float
      t.column "altitude",      :float
      t.column "speed",         :float
      t.column "direction",     :float
      t.column "device_id",     :integer
      t.column "created_at",     :datetime
      t.column "updated_at",  :datetime
    end

=begin
    create_table "sensors", :force => true do |t|
      t.column "name",              :string,  :limit => 100
      t.column "address",           :string,  :limit => 50
      t.column "type",              :string,  :limit => 100
      t.column "recent_reading_id", :integer,                :default => 0
      t.column "timestamp",         :string,  :limit => 50
      t.column "device_id",         :integer
      t.column "created_at",     :datetime
      t.column "updated_at",  :datetime
    end
=end

    create_table "sessions", :force => true do |t|
      t.column "session_id", :string
      t.column "data",       :text
      t.column "updated_at", :datetime
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"
  end
  
  def self.down
     #drop_table :accounts
     #drop_table :customers
     drop_table :users
     drop_table :devices
     drop_table :geofences
     #drop_table :locations
     drop_table :readings
     #drop_table :sensors
     drop_table :sessions
  end
end
  
  
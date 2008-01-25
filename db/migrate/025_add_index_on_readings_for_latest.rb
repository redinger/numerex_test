class AddIndexOnReadingsForLatest < ActiveRecord::Migration
  def self.up
    add_index :readings, [:device_id, :created_at], :name => 'readings_device_id_created_at'
    add_index "readings", ["device_id"], :name => "readings_device_id"
    add_index "readings", ["created_at"], :name => "readings_created_at"
    add_index "readings", ["address"], :name => "readings_address"
  end
  
  def self.down
    remove_index :readings, :name => :readings_device_id_created_at
    add_index "readings", ["device_id"], :name => "readings_device_id"
    add_index "readings", ["created_at"], :name => "readings_created_at"
    add_index "readings", ["address"], :name => "readings_address"
  end
end

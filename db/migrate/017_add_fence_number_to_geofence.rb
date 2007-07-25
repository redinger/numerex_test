class AddFenceNumberToGeofence < ActiveRecord::Migration
  def self.up
    add_column :geofences, :fence_num, :integer
  end

  def self.down
    remove_column :geofences, :fence_num
  end
end

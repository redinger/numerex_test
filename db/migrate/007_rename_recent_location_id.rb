class RenameRecentLocationId < ActiveRecord::Migration
  def self.up
    rename_column :devices, :recent_location_id, :recent_reading_id
    change_column :devices, :recent_reading_id, :integer, :default => 0
  end

  def self.down
    rename_column :devices, :recent_reading_id, :recent_location_id
    change_column :devices, :recent_location_id, :integer, :default => 0
  end
end

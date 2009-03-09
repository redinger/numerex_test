class ChangeRecentLocationId < ActiveRecord::Migration
  def self.up
    change_column :devices, :recent_location_id, :integer, :default => 0
  end

  def self.down
    change_column :devices, :recent_location_id, :integer
  end
end

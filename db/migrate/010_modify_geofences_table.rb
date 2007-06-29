class ModifyGeofencesTable < ActiveRecord::Migration
  def self.up
    rename_column :geofences, :perimeter, :bounds
    rename_column :geofences, :type, :is_radial
    change_column :geofences, :is_radial, :boolean, :default => 1
  end

  def self.down
    change_column :geofences, :is_radial, :integer, :size => 4
    rename_column :geofences, :is_radial, :type
    rename_column :geofences, :bounds, :perimeter
  end
end

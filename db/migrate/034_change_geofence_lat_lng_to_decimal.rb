class ChangeGeofenceLatLngToDecimal < ActiveRecord::Migration
  def self.up
    change_column :geofences, :latitude, :decimal, :precision => 15, :scale => 10
    change_column :geofences, :longitude, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    change_column :geofences, :latitude, :float
    change_column :geofences, :longitude, :float
  end
end

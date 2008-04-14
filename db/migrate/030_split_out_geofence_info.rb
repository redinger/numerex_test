class SplitOutGeofenceInfo < ActiveRecord::Migration
  def self.up
    add_column :geofences, :latitude, :float
    add_column :geofences, :longitude, :float
    add_column :geofences, :radius, :float
    remove_column :geofences, :is_radial
    execute "create table temp_geofences like geofences;"
    execute "INSERT INTO temp_geofences SELECT * FROM geofences;"
    execute "update temp_geofences tg set latitude=(select substring_index(bounds,',',1) from geofences where tg.id=id) where id=tg.id;"
    execute "update temp_geofences tg set longitude=(select substring_index(substring_index(bounds,',',2),',',-1) from geofences where tg.id=id) where id=tg.id;"
    execute "update temp_geofences tg set radius=(select substring_index(bounds,',',-1) from geofences where tg.id=id) where id=tg.id;"
    execute "DELETE FROM geofences;"
    execute "INSERT INTO geofences SELECT * FROM temp_geofences;"
    execute "drop table temp_geofences"
    remove_column :geofences, :bounds
  end

  def self.down
    remove_column :geofences, :latitude
    remove_column :geofences, :longitude
    remove_column :geofences, :radius
    add_column :geofences, :is_radial, :boolean, :default => 1
  end
end

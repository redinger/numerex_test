class CreateGeofenceViolations < ActiveRecord::Migration
  def self.up
    create_table :geofence_violations, :id => false do |t|
      t.column :device_id, :integer, :null => false
      t.column :geofence_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :geofence_violations
  end
end
  
class AddAddressToGeofencesTable < ActiveRecord::Migration
  def self.up
    add_column :geofences, :address, :string
  end

  def self.down
    remove_column :geofences, :address
  end
end

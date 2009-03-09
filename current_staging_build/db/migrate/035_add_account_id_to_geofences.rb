class AddAccountIdToGeofences < ActiveRecord::Migration
  def self.up
    add_column :geofences, :account_id, :integer
  end

  def self.down
    remove_column :geofences, :account_id
  end
end

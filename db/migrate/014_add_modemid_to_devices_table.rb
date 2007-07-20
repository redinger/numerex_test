class AddModemIdToDevicesTable < ActiveRecord::Migration 
  def self.up
    add_column :devices, :modem_id, :string, :limit => 30
  end

  def self.down
    remove_column :devices, :modem_id
  end
end

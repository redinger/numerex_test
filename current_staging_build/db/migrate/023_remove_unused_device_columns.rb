class RemoveUnusedDeviceColumns < ActiveRecord::Migration
  def self.up
    remove_column :devices, :modem_id
    remove_column :devices, :ip_address
  end

  def self.down
    add_column :devices, :modem_id, :string, :limit => 30
    add_column :devices, :ip_address, :string
  end
end

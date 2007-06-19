class AddProvisionStatusToDevicesTable < ActiveRecord::Migration
  def self.up
    add_column :devices, :provision_status_id, :integer, :limit => 2, :default => 0
  end

  def self.down
    remove_colum :devices, :provision_status_id
  end
end

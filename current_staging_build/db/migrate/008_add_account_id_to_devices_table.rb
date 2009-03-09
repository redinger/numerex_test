class AddAccountIdToDevicesTable < ActiveRecord::Migration
  def self.up
    add_column :devices, :account_id, :integer, :default => 0
  end

  def self.down
    remove_column :devices, :account_id
  end
end

class AddIsPublicToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :is_public, :integer, :default => 0
  end

  def self.down
    remove_column :devices, :is_public
  end
end

  class AlterDeviceTable < ActiveRecord::Migration
    def self.up
      add_column :devices, :icon_id, :integer, :default => 1
    end

    def self.down
      remove_column :devices, :icon_id
    end
  end
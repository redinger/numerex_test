class AddTransientToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :transient, :boolean
  end

  def self.down
    remove_column :devices, :transient
  end
end

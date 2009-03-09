class AddAddressToReadings < ActiveRecord::Migration
  def self.up
    add_column :readings, :address, :string, :limit => 1024
  end

  def self.down
    remove_column :readings, :address
  end
end

class BreakoutAddress < ActiveRecord::Migration
  def self.up
    add_column :readings, :geocoded, :boolean, :null => false, :default => 0
    add_column :readings, :street_number, :string
    add_column :readings, :street, :string
    add_column :readings, :place_name, :string
    add_column :readings, :admin_name1, :string
  end

  def self.down
    remove_column :readings, :geocoded
    remove_column :readings, :street_number
    remove_column :readings, :street
    remove_column :readings, :place_name
    remove_column :readings, :admin_name1
  end
end
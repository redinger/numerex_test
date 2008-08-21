class AddIo < ActiveRecord::Migration
  def self.up
    add_column :readings, :ignition, :boolean
    add_column :readings, :gpio1, :boolean
    add_column :readings, :gpio2, :boolean
  end

  def self.down
    remove_column :readings, :ignition
    remove_column :readigns, :gpio1
    remove_column :readings, :gpio2
  end
end

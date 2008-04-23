class AddLastOnline < ActiveRecord::Migration
  def self.up
    add_column :devices, :last_online_time, :datetime
  end

  def self.down
    remove_column :devices, :last_online_time
  end
end

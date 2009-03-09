class AddOnlineThresholdToDevice < ActiveRecord::Migration
  def self.up
    add_column :devices, :online_threshold, :integer
  end

  def self.down
    remove_column :devices, :online_threshold
  end
end

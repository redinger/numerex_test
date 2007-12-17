class ChangeDefaultThresholdTime < ActiveRecord::Migration
  def self.up
    change_column :devices, :online_threshold, :integer, :default => 90
  end

  def self.down
    change_column :devices, :online_threshold, :integer, :default => :null
  end
end

class ChangeColumnFromUsers < ActiveRecord::Migration
  def self.up
      change_column :users, :enotify, :integer, :default=>0, :limit=>1
  end

  def self.down
      change_column :users, :enotify, :boolean, :default=>0
  end
end

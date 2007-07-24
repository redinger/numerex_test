class ChangeForNotifications < ActiveRecord::Migration
  def self.up
    add_column :readings, :notified, :string
    add_column :users, :enotify, :boolean, :default => 0
    add_column :users, :notifycount, :integer, :default => 20
  end

  def self.down
    remove_column :readings, :notified
    remove_column :users, :enotify
    remove_column :users, :notifycount
  end
end

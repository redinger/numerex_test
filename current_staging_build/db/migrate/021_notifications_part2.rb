class NotificationsPart2 < ActiveRecord::Migration
  def self.up
    remove_column :readings, :notified
    remove_column :users, :notifycount
    add_column :readings, :notified, :boolean, :default => 0
    execute "update readings set notified=1"
  end

  def self.down
    remove_column :readings, :notified
    add_column :readings, :notified, :string
    add_column :users, :notifycount, :integer, :default => 20
  end
end

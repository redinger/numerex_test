class AddFlagToReadings < ActiveRecord::Migration
  def self.up
    add_column :readings, :notified, :string
  end

  def self.down
    remove_column :readings, :notified
  end
end

class AddNotifyFlagToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notify, :integer, :default='0'
    add_column :users, :notifycount, :integer, :default='20'
  end

  def self.down
    remove_column :users, :notify
    remove_column :users, :notifycount
  end
end

class AddNotificationsTable < ActiveRecord::Migration
  def self.up
    create_table :notifications, :force => true do |t|
      t.column "user_id", :integer
      t.column "device_id", :integer
      t.column "created_at", :datetime
      t.column "notification_type", :string, :limit => 25
    end
  end

  def self.down
    drop_table :notifications
  end
end

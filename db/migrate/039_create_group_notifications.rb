class CreateGroupNotifications < ActiveRecord::Migration
  def self.up
    create_table :group_notifications do |t|
        t.column :user_id, :integer
        t.column :group_id, :integer
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :group_notifications
  end
end

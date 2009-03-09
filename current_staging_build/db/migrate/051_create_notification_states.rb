class CreateNotificationStates < ActiveRecord::Migration
  def self.up
    create_table :notification_states do |t|
      t.column "last_reading_id",:integer,:null => false,:default => 0
    end
    
    NotificationState.instance.begin_reading_bounds
    NotificationState.instance.end_reading_bounds
  end

  def self.down
    drop_table :notification_states
  end
end

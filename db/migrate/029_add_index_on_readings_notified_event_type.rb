class AddIndexOnReadingsNotifiedEventType < ActiveRecord::Migration
  def self.up
    add_index :readings, [:notified, :event_type], :name => 'readings_notified_event_type'
  end

  def self.down
    remove_index :readings, :name => :readings_notified_event_type
  end
end

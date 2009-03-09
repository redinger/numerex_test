class CreateTripEventsTable < ActiveRecord::Migration
  def self.up
    create_table "trip_events", :force => true do |t|
      t.column "device_id", :integer
      t.column "reading_start_id", :integer
      t.column "reading_stop_id", :integer
      t.column "duration", :integer
      t.column "created_at", :datetime
    end
  end

  def self.down
    drop_table :trip_events
  end
end

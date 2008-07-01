class CreateStopEvents < ActiveRecord::Migration
def self.up
    create_table :stop_events  do |t|
     t.column "latitude",     :float
     t.column "longitude",    :float
     t.column "duration",     :integer
     t.column "device_id",    :integer
     t.column "created_at",  :datetime
    end
  end

  def self.down
    drop_table :stop_events
  end
end

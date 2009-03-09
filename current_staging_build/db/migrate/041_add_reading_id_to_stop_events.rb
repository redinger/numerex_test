class AddReadingIdToStopEvents < ActiveRecord::Migration
  def self.up
    add_column :stop_events, :reading_id, :integer
  end

  def self.down
    remove_column :stop_events, :reading_id
  end
end

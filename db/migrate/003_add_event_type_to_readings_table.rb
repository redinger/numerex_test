class AddEventTypeToReadingsTable < ActiveRecord::Migration
  def self.up
    add_column :readings, :event_type, :string, :limite => 25
  end

  def self.down
    remove_column :readings, :event_type
  end
end

class AddTripStats < ActiveRecord::Migration
  def self.up
    add_column :trip_events,:distance,:float
    add_column :trip_events,:idle,:integer
  end

  def self.down
    remove_column :trip_events,:distance
    remove_column :trip_events,:idle
  end
end

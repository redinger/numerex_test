class AddSpeedLimit < ActiveRecord::Migration
  def self.up
    add_column :accounts,:max_speed,:integer
    add_column :accounts,:allow_speed_exceptions,:boolean,:null => false,:default => false
    add_column :devices,:max_speed,:integer
    add_column :devices,:speeding_at,:datetime
  end

  def self.down
    remove_column :accounts,:max_speed
    remove_column :accounts,:allow_speed_exceptions
    remove_column :devices,:max_speed
    remove_column :devices,:speeding_at
  end
end

class FixStupidProblem < ActiveRecord::Migration
  def self.up
    remove_column :accounts,:allow_speed_exceptions
    remove_column :devices,:max_speed
  end

  def self.down
    add_column :accounts,:allow_speed_exceptions,:boolean,:null => true,:default => false
    add_column :devices,:max_speed,:integer
  end
end

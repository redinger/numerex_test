class AddAccountOptions < ActiveRecord::Migration
  def self.up
    add_column :accounts, :show_idle, :boolean, :default => false
    add_column :accounts, :show_runtime, :boolean, :default => false
    add_column :accounts, :show_statistics, :boolean, :default => false
    add_column :accounts, :show_maintenance, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :show_idle
    remove_column :accounts, :show_runtime
    remove_column :accounts, :show_statistics
    remove_column :accounts, :show_maintenance
  end
end

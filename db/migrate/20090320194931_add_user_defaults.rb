class AddUserDefaults < ActiveRecord::Migration
  def self.up
    add_column :users,:default_home_action,:string
    add_column :users,:default_home_selection,:string
    
    add_column :geofences,:notify_enter_exit,:boolean,:null => false,:default => false
  end

  def self.down
    remove_column :users,:default_home_action
    remove_column :users,:default_home_selection

    remove_column :geofences,:notify_enter_exit
  end
end

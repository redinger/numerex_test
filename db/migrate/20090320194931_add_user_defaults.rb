class AddUserDefaults < ActiveRecord::Migration
  def self.up
    add_column :users,:default_home_action,:string
    add_column :users,:default_home_selection,:string
  end

  def self.down
    remove_column :users,:default_home_action
    remove_column :users,:default_home_selection
  end
end

class AddSuperAdminColumn < ActiveRecord::Migration
  def self.up
    add_column :users, :is_super_admin, :boolean, :default => false
  end

  def self.down
    remove_column :users, :is_super_admin
  end
end
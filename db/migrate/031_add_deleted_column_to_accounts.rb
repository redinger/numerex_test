class AddDeletedColumnToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :is_deleted, :boolean, :default => false
  end

  def self.down
    remove_colum :accounts, :is_deleted
  end
end

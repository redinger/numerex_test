class AddIsVerifiedToAccountsTable < ActiveRecord::Migration
  def self.up
    add_column :accounts, :is_verified, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :is_verified
  end
end

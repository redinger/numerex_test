class AddLastLoginToUsersTable < ActiveRecord::Migration
  def self.up
    add_column :users, :last_login_dt, :datetime
  end

  def self.down
    remove_column :users, :last_login_dt
  end
end

class AddColumnAccessKeyToUserRelation < ActiveRecord::Migration
  def self.up
      add_column :users, :access_key, :string
  end

  def self.down
      remove_column :users, :access_key
  end
end

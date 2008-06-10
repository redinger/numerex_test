class AddColumnToDevicesRelation < ActiveRecord::Migration
  def self.up
      add_column :devices, :group_id, :integer
  end

  def self.down
      remove_column :devices, :group_id
  end
end

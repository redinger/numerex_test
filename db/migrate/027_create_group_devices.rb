class CreateGroupDevices < ActiveRecord::Migration
  def self.up
    create_table :group_devices do |t|
     
      t.column :device_id  ,   :integer
      t.column :group_id   ,   :integer
      t.column :account_id ,   :integer
      t.column :created_at ,  :datetime
   
      
    end
  end

  def self.down
    drop_table :group_devices
  end
end
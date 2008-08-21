class CreateDeviceProfiles < ActiveRecord::Migration
  def self.up
    create_table :device_profiles do |t|
      t.column "name",:string,:null => false
      t.column "speeds",:boolean,:null => false,:default => false
      t.column "stops",:boolean,:null => false,:default => false
      t.column "idles",:boolean,:null => false,:default => false
      t.column "runs",:boolean,:null => false,:default => false
      t.column "watch_gpio1",:boolean,:null => false,:default => false
      t.column "watch_gpio2",:boolean,:null => false,:default => false
      t.column "gpio1_labels",:string
      t.column "gpio2_labels",:string
    end
      
    execute "insert into device_profiles (id,name,speeds,stops) values (1,'Fleet Basic',1,1)"
    execute "insert into device_profiles (id,name,speeds,stops,idles,runs) values (2,'Fleet Plus',1,1,1,1)"
    execute "insert into device_profiles (id,name,runs,watch_gpio1,watch_gpio2,gpio1_labels,gpio2_labels) values (3,'Generic Machine',1,1,1,'GPIO\#1\tLOW\tHIGH\tGPIO\#1 is LOW\tGPIO\#1 is HIGH','GPIO\#2\tLOW\tHIGH\tGPIO\#2 is LOW\tGPIO#2 is HIGH')"
    execute "insert into device_profiles (id,name,runs,watch_gpio1,gpio1_labels) values (4,'Machine w/ Cut-Wire',1,1,'Cut-Wire\tCUT\tOK\tWire has been cut!\tConnection restored')"
    execute "insert into device_profiles (id,name,runs,watch_gpio1,gpio1_labels) values (5,'Tow Truck',1,1,'Tow Arm\tOff\tOn\t\t')"
    
    add_column :devices,:profile_id,:integer,:null => false,:default => 1
    add_column :devices,:last_gpio1,:boolean
    add_column :devices,:last_gpio2,:boolean
  end

  def self.down
    drop_table :device_profiles

    remove_column :devices,:profile_id
    remove_column :devices,:last_gpio1
    remove_column :devices,:last_gpio2
  end
end

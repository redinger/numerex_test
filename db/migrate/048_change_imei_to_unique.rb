class ChangeImeiToUnique < ActiveRecord::Migration
  def self.up
    execute "alter table devices change imei imei varchar(30) unique"
  end

  def self.down
    execute "alter table devices change imei imei varchar(30)"
  end
end

class Device < ActiveRecord::Base
  belongs_to :account
  has_many :readings, :order => "created_at desc", :limit => 10
  has_many :geofences, :order => "created_at desc", :limit => 3
  
  def self.get_devices(account_id)
    find(:all, :conditions => ['provision_status_id = 1 and account_id = ?', account_id])
  end
end

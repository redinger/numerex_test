class Device < ActiveRecord::Base
  belongs_to :account
  validates_uniqueness_of :imei
  has_many :readings, :order => "created_at desc", :limit => 1 # Gets the most recent reading
  has_many :geofences, :order => "created_at desc", :limit => 3
  
  # For now the provision_status_id is represented by
  # 0 = unprovisioned
  # 1 = provisioned
  # 2 = device deleted by user
  def self.get_devices(account_id)
    find(:all, :conditions => ['provision_status_id = 1 and account_id = ?', account_id])
  end
  
  def self.get_device(device_id, account_id)
    find(device_id, :conditions => ['provision_status_id = 1 and account_id = ?', account_id])
  end
end

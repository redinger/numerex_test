class Device < ActiveRecord::Base
  belongs_to :account
  validates_uniqueness_of :imei
  has_many :readings, :order => "created_at desc", :limit => 1 # Gets the most recent reading
  has_many :geofences, :order => "created_at desc", :limit => 3
  has_many :notifications, :order => "created_at desc"
 
  
  # For now the provision_status_id is represented by
  # 0 = unprovisioned
  # 1 = provisioned
  # 2 = device deleted by user
  def self.get_devices(account_id)
    find(:all, :conditions => ['provision_status_id = 1 and account_id = ?', account_id], :order => 'name')
  end
  
  def self.get_device(device_id, account_id)
    find(device_id, :conditions => ['provision_status_id = 1 and account_id = ?', account_id])
  end
  
  # Get names/ids for list box - don't want to get an entire devices object
  def self.get_names(account_id)
    find_by_sql(["select id, name from devices where account_id = ? and provision_status_id = 1 order by name", account_id])
  end
  
  def get_fence_by_num(fence_num)
    Geofence.find(:all, :conditions => ['device_id = ? and fence_num = ?', id, fence_num])[0]
  end
  
  def last_offline_notification
    Notification.find(:first, :order => 'created_at desc', :conditions => ['device_id = ? and notification_type = ?', id, "device_offline"])
  end
  
  def online?
    if(online_threshold.nil?)
       return true
    end
  
    if(!last_online_time.nil? && Time.now-last_online_time < online_threshold*60)
       return true
     else
      return false
    end
    puts Time.now - last_online_time
  end
end

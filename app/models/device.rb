class Device < ActiveRecord::Base
  STATUS_INACTIVE = 0
  STATUS_ACTIVE   = 1
  STATUS_DELETED  = 2

  belongs_to :account
  belongs_to :group
  belongs_to :profile,:class_name => 'DeviceProfile'
  
  validates_uniqueness_of :imei
  validates_presence_of :name, :imei
  
  has_one :latest_gps_reading, :class_name => "Reading", :order => "created_at desc", :conditions => "latitude is not null"
  has_one :latest_speed_reading, :class_name => "Reading", :order => "created_at desc", :conditions => "speed is not null"
  has_one :latest_data_reading, :class_name => "Reading", :order => "created_at desc", :conditions => "ignition is not null"
  
  has_many :geofences, :order => "created_at desc", :limit => 300
  has_many :notifications, :order => "created_at desc"
  has_many :stop_events, :order => "created_at desc"
  
  def self.logical_device_for_gateway_device(gateway_device)
    return gateway_device.logical_device if gateway_device.logical_device

    logical_device = find(:first,:conditions => "imei = '#{gateway_device.imei}'")

    # NOTE: ensure that SOMETHING is set as the logical device
    return (gateway_device.logical_device = new(:name => 'Not Found')) unless logical_device
    
    logical_device.gateway_device = gateway_device
    gateway_device.logical_device = logical_device
  end

  def self.friendly_name_for_gateway_device(gateway_device)
    return 'Undefined' unless gateway_device
    return gateway_device.friendly_name if gateway_device.friendly_name
    logical_device = logical_device_for_gateway_device(gateway_device)
    gateway_device.friendly_name = logical_device.name ? logical_device.name : 'Unassigned'
  end
  
  # For now the provision_status_id is represented by
  # 0 = unprovisioned
  # 1 = provisioned
  # 2 = device deleted by user
  def self.get_devices(account_id)
    find(:all, :conditions => ['provision_status_id = 1 and account_id = ?', account_id], :order => 'name',:include => :profile)
  end
  
  def self.get_public_devices(account_id)
    find(:all, :conditions => ['provision_status_id = 1 and account_id = ? and is_public = 1', account_id], :order => 'name')
  end
  
  def self.get_device(device_id, account_id)
    find(device_id, :conditions => ['provision_status_id = 1 and account_id = ?', account_id])
  end
  
  # Get names/ids for list box - don't want to get an entire devices object
  def self.get_names(account_id)
    find_by_sql(["select id, name from devices where account_id = ? and provision_status_id = 1 order by name", account_id])
  end
  
  def gateway_device
    return if @gateway_device == :false
    return @gateway_device if @gateway_device
    return unless (gateway = Gateway.find(gateway_name))
    find_statement = %(#{gateway.device_class}.find(:first,:conditions => "imei = '#{imei}'"))
    @gateway_device = (eval(find_statement) or :false)
    return if @gateway_device == :false
    @gateway_device.logical_device = self
    @gateway_device
  end
  
  def gateway_device=(value)
    @gateway_device = value
  end
  
  def get_fence_by_num(fence_num)
    Geofence.find(:all, :conditions => ['device_id = ? and fence_num = ?', id, fence_num])[0]
  end
  
  def last_offline_notification
    Notification.find(:first, :order => 'created_at desc', :conditions => ['device_id = ? and notification_type = ?', id, "device_offline"])
  end
  
  def latest_status
    results = []
    if profile.speeds and latest_speed_reading
      if latest_speed_reading.speed == 0
        results.push((profile.idles and latest_data_reading and latest_data_reading.ignition) ? "Idling" : "Stopped")
      else
        results.push((account.max_speed and latest_speed_reading.speed > account.max_speed) ? "<b><i>Speeding</i></b>" : "Moving")
      end
    end
    if latest_data_reading
      if profile.gpio1_name
        gpio1_value = (latest_data_reading.gpio1 ? profile.gpio1_high_value : profile.gpio1_low_value)
        gpio1_status = "#{profile.gpio1_name}: #{gpio1_value}" unless gpio1_value.blank?
      end
      if profile.gpio2_name
        gpio2_value = (latest_data_reading.gpio2 ? profile.gpio2_high_value : profile.gpio2_low_value)
        gpio2_status = "#{profile.gpio2_name}: #{gpio2_value}" unless gpio2_value.blank?
      end
      if profile.runs and not profile.idles
        value = latest_data_reading.ignition ? "On" : "Off"
        results.push((gpio1_status or gpio2_status) ? "Engine:&nbsp;#{value}" : value)
      end
      results.push(gpio1_status.gsub(/ /,'&nbsp;')) if gpio1_status
      results.push(gpio2_status.gsub(/ /,'&nbsp;')) if gpio2_status
    end
    results.join(', ') if results.any?
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
  end
end

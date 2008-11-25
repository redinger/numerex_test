class Device < ActiveRecord::Base
  STATUS_INACTIVE = 0
  STATUS_ACTIVE   = 1
  STATUS_DELETED  = 2
  
  REPORT_TYPE_ALL       = 0
  REPORT_TYPE_TRIP      = 1
  REPORT_TYPE_STOP      = 2
  REPORT_TYPE_IDLE      = 3
  REPORT_TYPE_SPEEDING  = 4
  REPORT_TYPE_RUNTIME   = 5
  REPORT_TYPE_GPIO1     = 6
  REPORT_TYPE_GPIO2     = 7

  belongs_to :account
  belongs_to :group
  belongs_to :profile,:class_name => 'DeviceProfile'
  
  validates_uniqueness_of :imei
  validates_presence_of :name, :imei
  
  has_one :latest_gps_reading, :class_name => "Reading", :order => "created_at desc", :conditions => "latitude is not null"
  has_one :latest_speed_reading, :class_name => "Reading", :order => "created_at desc", :conditions => "speed is not null"
  has_one :latest_data_reading, :class_name => "Reading", :order => "created_at desc", :conditions => "ignition is not null"
  has_one :latest_idle_event, :class_name => "IdleEvent", :order => "created_at desc"
  has_one :latest_runtime_event, :class_name => "RuntimeEvent", :order => "created_at desc"
  has_one :latest_stop_event, :class_name => "StopEvent", :order => "created_at desc"
  
  has_many :geofences, :order => "created_at desc", :limit => 300
  has_many :notifications, :order => "created_at desc"
  has_many :stop_events, :order => "created_at desc"
  has_many :trip_events, :order => "created_at desc"
  
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
    return [REPORT_TYPE_TRIP,"Offline"] unless online?
    
    results = nil
    
    if profile.idles and latest_idle_event and latest_idle_event.duration.nil?
      results = [REPORT_TYPE_IDLE,"Idling"]
    elsif profile.stops and latest_stop_event and latest_stop_event.duration.nil?
      results = [REPORT_TYPE_STOP,"Stopped"]
    elsif profile.speeds and latest_speed_reading
      if account.max_speed and latest_speed_reading.speed > account.max_speed
        results = [REPORT_TYPE_SPEEDING,"Speeding (#{latest_speed_reading.speed}mph)"]
      else
        results = [REPORT_TYPE_TRIP,"Moving"]
      end
    end

    results = [REPORT_TYPE_RUNTIME,latest_runtime_event.duration.nil? ? "On" : "Off"]  if profile.runs and results.nil? and latest_runtime_event

    if profile.gpio1_name and latest_data_reading
      gpio1_status = (latest_data_reading.gpio1 ? profile.gpio1_high_status : profile.gpio1_low_status)
      results = [REPORT_TYPE_GPIO1,gpio1_status] unless gpio1_status.blank?
    end
    
    if profile.gpio2_name and latest_data_reading
      gpio2_status = (latest_data_reading.gpio2 ? profile.gpio2_high_status : profile.gpio2_low_status)
      results = [REPORT_TYPE_GPIO2,gpio2_status] unless gpio2_status.blank?
    end
    
    results
  end
  
  def online?
    return false if transient
    return true unless online_threshold
    return false unless last_online_time
    return (Time.now - last_online_time) < (online_threshold * 60)
  end
end

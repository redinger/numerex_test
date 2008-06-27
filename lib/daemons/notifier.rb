#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../../config/environment"

$running = true;
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  logger = ActiveRecord::Base.logger
  logger.info("This notification daemon is still running at #{Time.now}.\n")

  readings_to_notify = Reading.find(:all, :conditions => "notified='0' and (event_type LIKE 'entergeofen%' OR event_type LIKE 'exitgeofen%')")

  logger.info("Notification needed for #{readings_to_notify.size.to_s} readings\n")
  
  readings_to_notify.each do |reading| 
    reading.device.account.users.each do |user|    
      if user.enotify == 1       
        logger.info("notifying: #{user.email}\n")
        action = reading.event_type.include?('exit') ? "exited geofence " : "entered geofence "
        action += reading.get_fence_name unless reading.get_fence_name.nil?
        mail = Notifier.deliver_notify_reading(user, action, reading)
      elsif user.enotify == 2         
          device_ids = user.group_devices_ids
         if  !device_ids.empty? && device_ids.include?(reading.device.id)
            logger.info("notifying: #{user.email}\n")
            action = reading.event_type.include?('exit') ? "exited geofence " : "entered geofence "
            action += reading.get_fence_name unless reading.get_fence_name.nil?
            mail = Notifier.deliver_notify_reading(user, action, reading)            
         end    
      end    
    end
    reading.notified = true
    reading.save    
  end
  
  devices_to_notify = Device.find(:all, :conditions => "(unix_timestamp(now())-unix_timestamp(last_online_time))/60>online_threshold and provision_status_id=1")
  devices_to_notify.each do |device| 
    last_notification = device.last_offline_notification
    if(last_notification.nil? || Time.now - last_notification.created_at > 24*60*60)
      device.account.users.each do |user|
        if user.enotify == 1
          logger.info("device offline, notifying: #{user.email}\n")
          mail = Notifier.deliver_device_offline(user, device)         
        elsif user.enotify == 2
             devices_ids = user.group_devices_ids
             if !devices_ids.empty? || devices_ids.include?(device.id)
              logger.info("device offline, notifying: #{user.email}\n")
              mail = Notifier.deliver_device_offline(user, device)                         
             end    
        end
         if user.enotify != 0
          notification = Notification.new
          notification.user_id = user.id
          notification.device_id = device.id
          notification.notification_type = "device_offline"
          notification.save   
         end 
        end
      end
    #end    
  end
    
  
  sleep 10

end

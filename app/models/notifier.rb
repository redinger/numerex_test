class Notifier < ActionMailer::Base
  
  def self.send_geofence_notifications(logger)
    # NOTE: eliminate legacy geofences 'entergeofence_et11' and 'exitgeofence_et52'
    readings_to_notify = Reading.find(:all, :conditions => "notified='0' and (event_type LIKE 'entergeofen%' OR event_type LIKE 'exitgeofen%') and event_type != 'entergeofen_et11' and event_type != 'exitgeofen_et52'")
  
    logger.info("Notification needed for #{readings_to_notify.size.to_s} readings\n")
    
    readings_to_notify.each do |reading|
      action = reading.event_type.include?('exit') ? "exited geofence " : "entered geofence "
      action += reading.get_fence_name unless reading.get_fence_name.nil?
      send_notify_reading_to_users(action,reading)
      reading.notified = true
      reading.save    
    end
  end
  
  def self.send_device_offline_notifications(logger)
    devices_to_notify = Device.find(:all, :conditions => "(unix_timestamp(now())-unix_timestamp(last_online_time))/60>online_threshold and provision_status_id=1")
    devices_to_notify.each do |device| 
      last_notification = device.last_offline_notification
      if (last_notification.nil? || Time.now - last_notification.created_at > 24*60*60)
        device.account.users.each do |user|
          if user.enotify == 1
            logger.info("device offline, notifying: #{user.email}\n")
            mail = deliver_device_offline(user, device)         
          elsif user.enotify == 2
            devices_ids = user.group_devices_ids
            if !devices_ids.empty? || devices_ids.include?(device.id)
              logger.info("device offline, notifying: #{user.email}\n")
              mail = deliver_device_offline(user, device)                         
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
    end
  end
  
  def self.send_gpio_notifications(logger)
    devices_to_notify = Device.find_by_sql("select devices.* from devices,device_profiles where profile_id = device_profiles.id and provision_status_id = 1 and (watch_gpio1 or device_profiles.watch_gpio2)")
    devices_to_notify.each do |device|
      readings_to_notify = Reading.find(:all,:conditions => "notified=0 and device_id = #{device.id} and gpio1 is not null") # NOTE: assumes if gpio1 is not null, then gpio2 is not null also
      readings_to_notify.each do |reading|
        if device.last_gpio1.nil?
          device.last_gpio1 = reading.gpio1
          device.save
        elsif device.profile.watch_gpio1 and not reading.gpio1.eql?(device.last_gpio1)
          device.last_gpio1 = reading.gpio1
          device.save
          action = reading.gpio1 ? device.profile.gpio1_high_notice : device.profile.gpio1_low_notice
          send_notify_reading_to_users(action,reading) if action
        end
        if device.last_gpio2.nil?
          device.last_gpio2 = reading.gpio2
          device.save
        elsif device.profile.watch_gpio2 and reading.gpio2 != device.last_gpio2
          device.last_gpio2 = reading.gpio2
          device.save
          action = reading.gpio2 ? device.profile.gpio2_high_notice : device.profile.gpio2_low_notice
          send_notify_reading_to_users(action,reading) if action
        end
        reading.notified = true
        reading.save    
      end
    end
  end
  
  def self.send_notify_reading_to_users(action,reading)
    reading.device.account.users.each do |user|
      if user.enotify == 1       
        logger.info("notifying(1): #{user.email} about: #{action}\n")
        mail = deliver_notify_reading(user, action, reading)
      elsif user.enotify == 2         
        device_ids = user.group_devices_ids
        if  !device_ids.empty? && device_ids.include?(reading.device.id)
          logger.info("notifying(2): #{user.email} about: #{action}\n")
          mail = deliver_notify_reading(user, action, reading)            
        end    
      end    
    end
  end

  def forgot_password(user, url=nil)
    setup_email(user)

    @subject = "Forgotten Password Notification"

    # Email body substitutions
    @body["name"] = "#{user.first_name} #{user.last_name}"
    @body["login"] = user.email
    @body["url"] = url
    @body["app_name"] = "Ublip"
  end

  def change_password(user, password, url=nil)
    setup_email(user)

    # Email header info
    @subject = "Changed Password Notification"

    # Email body substitutions
    @body["name"] = "#{user.first_name} #{user.last_name}"
    @body["login"] = user.email
    @body["password"] = password
    @body["url"] = url 
    @body["app_name"] = "Ublip"
  end

  def notify_reading(user, action, reading)
    @recipients = user.email
    @from = "alerts@ublip.com"
    @subject = reading.device.name + ' ' + action
    @body["action"] = action
    @body["name"] = "#{user.first_name} #{user.last_name}"
    @body["device_name"] = reading.device.name
    #tz = user.time_zone.nil? ? TimeZone.us_zones[5] : TimeZone.new(user.time_zone)
    #@body["time"] = tz.adjust(reading.created_at)
    #@body["time_zone"] = tz.to_s.split(/[\(\\s)]/)[2].strip
  end
  
  def device_offline(user, device)
    @recipients = user.email
    @from = "alerts@ublip.com"
    @subject = "Device Offline Notification"
    @body["device_name"] = device.name
    @body["last_online"] = device.last_online_time
    @body["name"] = "#{user.first_name} #{user.last_name}"
  end

  def setup_email(user)
    @recipients = "#{user.email}"
    @from       = "support@ublip.com"
    @sent_on    = Time.now
    @headers['Content-Type'] = "text/plain; charset=utf-16"
  end
  
  # Send email to support from contact page
  def app_feedback(email, subdomain, feedback)
    @from = "support@ublip.com"
    @recipients = "support@ublip.com"
    @subject = "Feedback from #{subdomain}.ublip.com"
    @body["feedback"] = feedback
    @body["sender"] = email
  end
  
  # Send a confirmation when an order is placed
  def order_confirmation(order_id, cust, order_details, email, password, subdomain)
    @from = "orders@ublip.com"
    @recipients = email
    @bcc = "orders@ublip.com"
    @subject = "Thank you for ordering from Ublip"
    @body["order_id"] = order_id
    @body["ship_company"] = cust[:ship_company]
    @body["ship_first_name"] = cust[:ship_first_name]
    @body["ship_last_name"] = cust[:ship_last_name]
    @body["ship_address"] = cust[:ship_address]
    @body["ship_city"] = cust[:ship_city]
    @body["ship_state"] = cust[:ship_state]
    @body["ship_zip"] = cust[:ship_zip]
    @body["bill_company"] = cust[:bill_company]
    @body["bill_first_name"] = cust[:bill_first_name]
    @body["bill_last_name"] = cust[:bill_last_name]
    @body["bill_address"] = cust[:bill_address]
    @body["bill_city"] = cust[:bill_city]
    @body["bill_state"] = cust[:bill_state]
    @body["bill_zip"] = cust[:bill_zip]
    @body["qty"] = order_details[:qty]
    @body["service_code"] = order_details[:service_code]
    @body["service_price"] = order_details[:service_price]
    @body["subtotal"] = order_details[:subtotal]
    @body["tax"] = order_details[:tax]
    @body["shipping"] = order_details[:shipping]
    @body["total"] = order_details[:total]
    @body["device_code"] = order_details[:device_code]
    @body["email"] = email 
    @body["password"] = password
    @body["subdomain"] = subdomain
  end
end

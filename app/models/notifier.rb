class Notifier < ActionMailer::Base

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
    tz = TimeZone.new(user.time_zone)
    @body["time"] = tz.adjust(reading.created_at)
    @body["time_zone"] = tz.to_s.split(/[\(\\s)]/)[2].strip
    
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

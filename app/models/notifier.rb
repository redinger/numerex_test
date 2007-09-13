class Notifier < ActionMailer::Base

def forgot_password(user, url=nil)
    setup_email(user)

    # Email header info
    @subject += "Forgotten password notification"

    # Email body substitutions
    @body["name"] = "#{user.first_name} #{user.last_name}"
    @body["login"] = user.email
    @body["url"] = url
    @body["app_name"] = "Ublip"
  end

  def change_password(user, password, url=nil)
    setup_email(user)

    # Email header info
    @subject += "Changed password notification"

    # Email body substitutions
    @body["name"] = "#{user.first_name} #{user.last_name}"
    @body["login"] = user.email
    @body["password"] = password
    @body["url"] = url 
    @body["app_name"] = "Ublip"
  end

  def notify_reading(user, action, reading)
    setup_email(user)
    @subject = reading.device.name + ' ' + action
    @body["action"] = action
    @body["name"] = "#{user.first_name} #{user.last_name}"
    @body["device_name"] = reading.device.name
    @body["time"] = reading.created_at
  end

   def setup_email(user)
    @recipients = "#{user.email}"
    @from       = "support@ublip.com"
    @subject    = "Forgotten Password request"
    @sent_on    = Time.now
    @headers['Content-Type'] = "text/plain; charset=utf-16"
  end
  
  # Send a confirmation when an order is placed
  def order_confirmation(cust, email, password, subdomain)
    @from = "orders@ublip.com"
    @recipients = email
    @bcc = "orders@ublip.com"
    @subject = "Thank you for ordering from Ublip"
    @body["name"] = cust[:ship_first_name]
    @body["email"] = email
    @body["password"] = password
    @body["subdomain"] = subdomain
  end
end

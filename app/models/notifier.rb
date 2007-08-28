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


   def setup_email(user)
    @recipients = "#{user.email}"
    @from       = "Ublip.com"
    @subject    = "Forgotten Password request"
    @sent_on    = Time.now
    @headers['Content-Type'] = "text/plain; charset=utf-16"
  end
end

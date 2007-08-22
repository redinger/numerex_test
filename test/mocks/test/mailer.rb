require "models/mailer"

class Mailer < ActionMailer::Base
  
  
  def Mailer.deliver_registration_confirmation(user, key)
    @@last_key = key
    puts "sending a mail to " + user.email.to_s + " with key " + key.to_s
  end
  
  def Mailer.get_last_key
    @@last_key
  end
  
end

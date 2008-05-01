class Mailer < ActionMailer::Base
  
  # Send an email to the newly subscribed user
  def registration_confirmation(user, key)
    @subject = 'Your Ublip account has been created!'
    @recipients = user.email
    @from = 'Ublip Accounts <accounts@ublip.com>'
    @body['user'] = user
    @body['account'] = user.account
    @body['key'] = key
  end
  
end

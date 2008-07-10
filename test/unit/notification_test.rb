require File.dirname(__FILE__) + '/../test_helper'

class NotificationTest < Test::Unit::TestCase
  fixtures :notifications, :users, :readings, :devices

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  
  # Replace this with your real tests.
  def test_truth
    assert_equal "device_offline", notifications(:one).notification_type.to_s
  end
  
  def test_notify_device_offline
    user = users(:dennis)
    device = devices(:device1)
    response = Notifier.deliver_device_offline(user, device)
    assert_equal 'Device Offline Notification', response.subject
    assert_match /Dear #{user.first_name} #{user.last_name},\n\ndevice 1 seems to be offline/, response.body
  end
  
  def test_notify_forgot_password
    user = users(:dennis)
    response = Notifier.deliver_forgot_password(user, "http://a.com")
    assert_equal 'Forgotten Password Notification', response.subject
    assert_equal user.email, response.destinations[0]
  end
  
  def test_notify_change_password
    user = users(:dennis)
    response = Notifier.deliver_change_password(user, "http://a.com")
    assert_equal 'Changed Password Notification', response.subject
    assert_equal user.email, response.destinations[0]
  end
  
  def test_notify_app_feedback
    user = users(:dennis)
    response = Notifier.deliver_app_feedback(user, "qwerty", "your app rocks!")
    assert_equal 'Feedback from qwerty.ublip.com', response.subject
    assert_equal "support@ublip.com", response.destinations[0]
  end
  
   def test_notify_order_confirmation
    user = users(:dennis)
    response = Notifier.deliver_order_confirmation(42, 42, "order_details", user.email, "password", "qwerty")
    assert_equal 'Thank you for ordering from Ublip', response.subject
    assert_equal user.email, response.destinations[0]
  end
end

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
  
  def test_notify_geofence_exception
    user = users(:dennis)
    reading = readings(:readings_049) # Geofence exception reading
    # Action code from notifier daemon
    action = reading.event_type.include?('exit') ? "exited geofence " : "entered geofence "
    action += reading.get_fence_name unless reading.get_fence_name.nil?
    response = Notifier.deliver_notify_reading(user, action, reading)
    assert_equal 'device 1 exited geofence home', response.subject
    assert_match /Dear #{user.first_name} #{user.last_name}/, response.body
  end
  
  def test_notify_device_offline
    user = users(:dennis)
    device = devices(:device1)
    response = Notifier.deliver_device_offline(user, device)
    assert_equal 'Device Offline Notification', response.subject
    assert_match /Dear #{user.first_name} #{user.last_name},\n\ndevice 1 seems to be offline/, response.body
  end
end

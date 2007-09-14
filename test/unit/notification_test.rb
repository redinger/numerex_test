require File.dirname(__FILE__) + '/../test_helper'

class NotificationTest < Test::Unit::TestCase
  fixtures :notifications

  # Replace this with your real tests.
  def test_truth
    assert_equal "device_offline", notifications(:one).notification_type.to_s
  end
end

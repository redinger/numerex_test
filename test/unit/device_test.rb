require File.dirname(__FILE__) + '/../test_helper'

class DeviceTest < Test::Unit::TestCase
  fixtures :devices, :geofences, :notifications

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_get_fence
    fence = devices(:device1).get_fence_by_num(1)
    assert_equal geofences(:fenceOne), fence
    
     fence = devices(:device1).get_fence_by_num(2)
    assert_nil fence
    
    fence = devices(:device2).get_fence_by_num(2)
    assert_nil fence
  end
  
  def test_online
    assert_equal true, devices(:device1).online?
    assert_equal false, devices(:device2).online?
    assert_equal false, devices(:device3).online?
    assert_equal true, devices(:device4).online?
  end
  
  def test_last_offline_notification
    last_offline_notification = devices(:device1).last_offline_notification
    assert_equal 2, last_offline_notification.id
  end
end

require File.dirname(__FILE__) + '/../test_helper'

class DeviceTest < Test::Unit::TestCase
  fixtures :devices, :accounts, :geofences, :notifications, :device_profiles, :readings, :stop_events, :idle_events, :runtime_events

  # Replace this with your real tests.
  def test_get_by_device_and_account
    device = Device.get_device(1,1)
    assert_not_nil device
    assert_equal "device 1", device.name
  end
  
  def test_get_device_by_account
    devices = Device.get_devices(1)
    assert_not_nil devices
    assert_equal 5, devices.size
  end
  
  def test_get_names_by_account
    devices = Device.get_names(1)
    assert_not_nil devices
    assert_equal 5, devices.size
  end
  
  def test_get_fence
    fence = devices(:device1).get_fence_by_num(1)
    assert_equal geofences(:fenceOne), fence
    
    fence = devices(:device1).get_fence_by_num(4)
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
  
  def test_latest_status
    assert_equal [Device::REPORT_TYPE_STOP,"Stopped"],devices(:device1).latest_status
    assert_equal [Device::REPORT_TYPE_IDLE,"Idling"],devices(:device2).latest_status
    assert_equal [Device::REPORT_TYPE_TRIP,"Moving"],devices(:device3).latest_status
    assert_equal nil,devices(:device4).latest_status
    assert_equal [Device::REPORT_TYPE_SPEEDING,"Speeding (31mph)"],devices(:device6).latest_status
    assert_equal [Device::REPORT_TYPE_RUNTIME,"On"],devices(:device7).latest_status
    assert_equal [Device::REPORT_TYPE_GPIO1,"HIGH STATUS"],devices(:device8).latest_status
  end
end

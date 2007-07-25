require File.dirname(__FILE__) + '/../test_helper'

class GeofenceTest < Test::Unit::TestCase
  fixtures :geofences, :devices
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  
  def test_unique
    fence1 = Geofence.new 
    fence1.device_id = 1
    fence1.fence_num = 1
    fence1.save
    
    fence2 = Geofence.new 
    fence2.device_id = 2
    fence2.fence_num = 1
    fence2.save!
    
    begin
      fence3 = Geofence.new 
      fence3.fence_num = 1
      fence3.device_id = 2
      fence3.save!
      fail "should have thrown exception"
    rescue
      puts $!
    end
  end
  
  def test_find_fence_number
    fence = Geofence.new
    fence.device_id = 1
    fence.find_fence_num
    assert_equal 2, fence.fence_num
    fence.save
    
    fence2 = Geofence.new
    fence2.device_id = 1
    fence2.find_fence_num
    assert_equal 4, fence2.fence_num
    fence2.save
    
    fence3 = Geofence.new
    fence2.device_id = 1
    begin
      fence2.find_fence_num
      fail "should have thrown exception"
    rescue
      puts $!
    end
  end
end

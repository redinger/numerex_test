require File.dirname(__FILE__) + '/../test_helper'

class TriggerTest < Test::Unit::TestCase
  
  fixtures :geofences

  def setup
    
    ActiveRecord::Base.connection.execute("DELETE FROM geofence_violations")
    
    file = File.new("geofence.sql")
    file.readline
    file.readline  #skip 1st two lines of file
    sql = file.read
    statements = sql.split(';;')
    
    statements.each  {|stmt| 
          #puts stmt
          ActiveRecord::Base.connection.execute(stmt)
    }
    Reading.delete_all
  end
  
  def test_enter
    reading = save_reading(32.833781, -96.756807, 1)
    assert_equal "enter_geofen1", reading.event_type
    
    reading = save_reading(32.833782, -96.756807, 1)
    assert_nil reading.event_type
    
    reading = save_reading(33.833783, -96.756807, 1)
    assert_equal "exit_geofen1", reading.event_type
    
    reading = save_reading(32.833784, -96.756807, 1)
    assert_equal "enter_geofen1", reading.event_type
    
    reading = save_reading(32.940955, -96.822224, 1)
    assert_equal "enter_geofen3", reading.event_type
    
    reading = save_reading(32.940956, -96.822224, 1)
    assert_equal "exit_geofen1", reading.event_type
  end
  
  def save_reading(latitude, longitude, device_id)
    reading = Reading.new
    reading.latitude = latitude
    reading.longitude = longitude
    reading.device_id = device_id
    reading.save
    reading.reload
    return reading
  end

end


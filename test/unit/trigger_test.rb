require File.dirname(__FILE__) + '/../test_helper'

class TriggerTest < Test::Unit::TestCase
  
  fixtures :geofences, :devices, :accounts

  def setup
    
    ActiveRecord::Base.connection.execute("DELETE FROM geofence_violations")
    
    file = File.new("geofence.sql")
    file.readline
    file.readline  #skip 1st two lines of file
    sql = file.read
    statements = sql.split(';;')
    
    statements.each  {|stmt| 
          query = stmt.strip
          ActiveRecord::Base.connection.execute(query) if query.size > 0
    }
    Reading.delete_all
  end
  
  def teardown
    ActiveRecord::Base.connection.execute("DROP TRIGGER IF EXISTS trig_readings_before_insert")
  end
  
  def test_enter
    reading = save_reading(32.833781, -96.756807, 1)
    assert_equal "entergeofen_1", reading.event_type
    
    reading = save_reading(32.833782, -96.756807, 1)
    assert_nil reading.event_type
    
    reading = save_reading(33.833783, -96.756807, 1)
    assert_equal "exitgeofen_1", reading.event_type
    
    reading = save_reading(32.833784, -96.756807, 1)
    assert_equal "entergeofen_1", reading.event_type
    
    reading = save_reading(32.940955, -96.822224, 1)
    assert_equal "entergeofen_20", reading.event_type
    
    reading = save_reading(32.940956, -96.822224, 1)
    assert_equal "exitgeofen_1", reading.event_type
  end
  
  def test_account_level
    reading = save_reading(32.7977, -79.9603, 1)
    assert_equal "entergeofen_4", reading.event_type
    
    reading = save_reading(32.7977, -69.9603, 1)
    assert_equal "exitgeofen_4", reading.event_type
    
    reading = save_reading(32.7977, -69.9603, 2)
    assert_nil reading.event_type
    
    reading = save_reading(32.7977, -79.9603, 1)
    assert_equal "entergeofen_4", reading.event_type
    
    reading = save_reading(32.7977, -69.9603, 2)
    assert_nil reading.event_type
    
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


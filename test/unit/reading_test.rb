require File.dirname(__FILE__) + '/../test_helper'

class ReadingTest < Test::Unit::TestCase
  fixtures :readings, :geofences
  
  
  def test_address
    assert_equal "Bigfork, MT", readings(:reading5).short_address
    assert_equal "6762 Big Springs Dr, Arlington, TX", readings(:reading1).short_address
    assert_equal "Inwood Rd, Farmers Branch, TX", readings(:reading2).short_address
    assert_equal "32.9395, -96.8244", readings(:reading3).short_address
    assert_equal "32.94, -96.8217", readings(:reading4).short_address
    assert_equal "32.9514, -96.8228", readings(:reading6).short_address
  end
  
  def test_speed_round
    assert_equal 29, readings(:reading1).speed
    assert_equal 39, readings(:reading2).speed  
  end
  
  def test_null_speed
    assert_equal "N/A", readings(:reading3).speed
    assert_not_equal "N/A", readings(:reading4).speed
  end
  
  def test_distance
    reading1 = Reading.new
    reading1.latitude=32.6782
    reading1.longitude=-97.0449
    
    reading2 = Reading.new
    reading2.latitude=32.6782
    reading2.longitude=-97.0446
    
    reading3 = Reading.new
    reading3.latitude=32.6752
    reading3.longitude=-97.0425
    
    puts reading1.distance_to(reading2)*1000
    puts reading1.distance_to(reading3)*1000
  end
   
  def test_fence_name
    assert_nil readings(:reading1).get_fence_name
    assert_equal "work", readings(:readings_224).get_fence_name
    
    reading = readings(:reading1)
    reading.event_type="entergeofen_1234" #bad geofence ID
    assert_nil reading.get_fence_name()
  end

  end

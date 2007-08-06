require File.dirname(__FILE__) + '/../test_helper'

class ReadingTest < Test::Unit::TestCase
  fixtures :readings

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  
  def test_address
    assert_equal "Bigfork, Montana", readings(:reading5).shortAddress
    assert_equal "6762 Big Springs Dr, Arlington, Texas", readings(:reading1).shortAddress
    assert_equal "Inwood Rd, Farmers Branch, Texas", readings(:reading2).shortAddress
    assert_equal "32.9395, -96.8244", readings(:reading3).shortAddress
    assert_equal "32.94, -96.8217", readings(:reading4).shortAddress
  end
  
  
  def test_speed_round
    assert_equal 29, readings(:reading1).speed
    assert_equal 39, readings(:reading2).speed  
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
   
  

  end

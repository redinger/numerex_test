require File.dirname(__FILE__) + '/../test_helper'

class ReadingTest < Test::Unit::TestCase
  fixtures :readings

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_address
    assert_equal "6760 Big Springs Dr, Arlington, Texas", readings(:reading1).address
    assert_equal "Inwood Rd, Farmers Branch, Texas", readings(:reading2).address
    
    Reading::ReverseGeocodeURL[8] = "A"  #muck up URL to create exception
    assert_equal "32.6358, -97.1757", readings(:reading1).address
  end
  
   
  

  end

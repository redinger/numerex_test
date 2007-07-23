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
  
   
  

  end

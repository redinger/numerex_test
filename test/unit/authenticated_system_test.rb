require File.dirname(__FILE__) + '/../test_helper'

class AuthenticatedSystemTest < Test::Unit::TestCase
  
require 'authenticated_system'
  
  
  # Replace this with your real tests.
  def test_logged_in	
    self.extend AuthenticatedSystem
    logged_in?
	end
  
  def session(*args)
    {:user => User.new}
  end
 

end

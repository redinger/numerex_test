require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  
  fixtures :users
  
  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_index
    get :index
  end
  
  def test_login
   @request.host="dennis.ublip.com"
   post :index, {:email => users(:dennis).email, :password => "testing"} 
   assert_redirected_to "/home"
 end
 
 def test_login_same_email_diff_act
   @request.host="nick.ublip.com"
   post :index, {:email => users(:dennis).email, :password => "testing"} 
   assert_redirected_to "/home"
 end
 
 def test_login_failure
   @request.host="dennis.ublip.com"
   post :index, {:email => users(:dennis).email, :password => "wrong"} 
   assert_redirected_to "/login"
 end
 
 def test_logout
   get :logout
   assert_redirected_to "/login"
 end
 
end

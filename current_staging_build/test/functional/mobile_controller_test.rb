require File.dirname(__FILE__) + '/../test_helper'
require 'mobile_controller'

# Re-raise errors caught by the controller.
class MobileController; def rescue_action(e) raise e end; end

class MobileControllerTest < Test::Unit::TestCase
    fixtures :users,:devices,:accounts  
  def setup
    @controller = MobileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_index
    get :index
    assert_response :success    
  end
   
   def test_devices
       get :devices, {},{:user => users(:dennis), :account_id => "1"} 
       assert_response :success    
   end    

   def test_show_device
       get :show_device, {:id=>"1"},{:user => users(:dennis), :account_id => "1"} 
       assert_response :success
   end
   
   def test_view_all
      get :view_all, {},{:user => users(:dennis), :account_id => "1"}   
      assert_response :success
   end
   
end

require File.dirname(__FILE__) + '/../test_helper'
require 'ws_controller'

# Re-raise errors caught by the controller.
class WsController; def rescue_action(e) raise e end; end

class WsControllerTest < Test::Unit::TestCase
  
  context "A WS instance" do
    setup do
      @controller = WsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
        
    context "without any parameters" do
      should "respond with 200 OK" do
        get :index
        assert_response :success
      end
      
      should "send return default message" do
        get :index
        assert_equal @response.body, "We're sorry, this device does not exist"
      end
    end
    
    context "with valid parameters" do
      should "return success message" do
        get :index, {:imei => "1234", :lat => 1, :lng => 2, :spd => 3, :dir => 4, :alt => 5}
        assert_equal @response.body, "Success"
      end
    end
    
  end
end

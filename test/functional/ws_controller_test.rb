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
      setup do
        Reading.delete_all
        get :index, {:imei => "1234", :lat => 1, :lng => 2, :spd => 3, :dir => 4, :alt => 5}
      end
      should_respond_with :success
      
      should "save one reading" do
        assert_equal 1, Reading.find(:all).size
      end
      
      should "save correct values" do
        reading = Reading.find(:first)
        assert_equal "1234", reading.device.imei
        assert_equal 1, reading.latitude
        assert_equal 2, reading.longitude
        assert_equal 3, reading.speed
        assert_equal 4, reading.direction
        assert_equal 5, reading.altitude
      end
    end
    
  end
end

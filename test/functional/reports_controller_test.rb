require File.dirname(__FILE__) + '/../test_helper'
require 'reports_controller'

# Re-raise errors caught by the controller.
class ReportsController; def rescue_action(e) raise e end; end

class ReportsControllerTest < Test::Unit::TestCase
  
  module PathInfo
    def path_info
      "asdf"
    end
  end
  
  fixtures :users, :readings
  
  def setup
    @controller = ReportsController.new
    @request    = ActionController::TestRequest.new 
    @response   = ActionController::TestResponse.new
    @request.extend(PathInfo)
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_stop
    
    pretend_now_is(Time.at(1185490000)) do
      get :stop, {:id=>"3", :t=>"1"}, { :user => users(:dennis) } 
      stops = assigns(:stops)
      assert_response :success
      assert_template "stop"
      assert_equal 3, stops.size
      assert_equal 900, stops[0].duration
      assert_equal 400, stops[1].duration
      assert_equal nil, stops[2].duration
      
      get :stop, {:id=>"3", :t=>"1", :p => "2"}, { :user => users(:dennis) }
      stops = assigns(:stops)
      assert_equal 2, stops.size
      assert_equal 500, stops[0].duration
      assert_equal nil, stops[1].duration
    end
  end
end

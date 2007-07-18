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
    get :stop, {:id=>"3"}, { :user => users(:dennis) } 
    assert_response :success
    assert_template "stop"
    stops = assigns(:stops)
    assert_equal 5, stops.size
    assert_equal 600, stops[0].duration
    assert_equal 100, stops[1].duration
    assert_equal nil, stops[2].duration
    assert_equal 200, stops[3].duration
    assert_equal nil, stops[4].duration
    
  end
end

require File.dirname(__FILE__) + '/../test_helper'
require 'admin_status_controller'

# Re-raise errors caught by the controller.
class AdminStatusController; def rescue_action(e) raise e end; end
  
class AdminStatusControllerTest < Test::Unit::TestCase
  def setup
    @controller = AdminStatusController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_up_check    
    get :up_check, {}, {}
    assert_response(:success)
    assert_match %r{Schema #: [0-9]+}, @response.body
  end
end

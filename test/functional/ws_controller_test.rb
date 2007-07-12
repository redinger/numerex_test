require File.dirname(__FILE__) + '/../test_helper'
require 'ws_controller'

# Re-raise errors caught by the controller.
class WsController; def rescue_action(e) raise e end; end

class WsControllerTest < Test::Unit::TestCase
  def setup
    @controller = WsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

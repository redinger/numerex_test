require File.dirname(__FILE__) + '/../test_helper'
require 'gateway_controller'

# Re-raise errors caught by the controller.
class GatewayController; def rescue_action(e) raise e end; end

class GatewayControllerTest < Test::Unit::TestCase
  def setup
    @controller = GatewayController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

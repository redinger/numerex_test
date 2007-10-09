require File.dirname(__FILE__) + '/../test_helper'
require 'gadget_controller'

# Re-raise errors caught by the controller.
class GadgetController; def rescue_action(e) raise e end; end

class GadgetControllerTest < Test::Unit::TestCase
  def setup
    @controller = GadgetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_all
     @request.host="dennis.ublip.com"
     get :all
     subdomain = assigns(:subdomain)
    assert_equal "dennis", subdomain
  end
end

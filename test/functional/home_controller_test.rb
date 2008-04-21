require File.dirname(__FILE__) + '/../test_helper'
require 'home_controller'


# Re-raise errors caught by the controller.
class HomeController; def rescue_action(e) raise e end; end

class HomeControllerTest < Test::Unit::TestCase
  
  fixtures :users, :accounts, :devices, :readings
  
  module RequestExtensions
    def server_name
      "helo"
    end
    def path_info
      "adsf"
    end
  end
  
  def setup
    @controller = HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end

  def test_index
    get :index, {}, {:user => users(:dennis)} 
    assert_response :success
  end
  
  def test_not_logged_in
    get :index
    assert_redirected_to :controller => "login"
    assert_equal flash[:message], "You're not currently logged in"
  end
  
  def test_map
    get :map, {}, {:user=>users(:dennis), :account_id => accounts(:dennis).id}
    assert_response :success
  end
  
end

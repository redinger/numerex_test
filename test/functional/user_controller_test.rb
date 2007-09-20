require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < Test::Unit::TestCase
  
  fixtures :users,:accounts
  
    module RequestExtensions
    def server_name
      "helo"
    end
    def path_info
      "adsf"
    end
  end
  
  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end

  def test_edit
#    params = {:first_name => "qwerty", :last_name => "asdf", :email =>"asdf", :password => "testing"}
#    post :edit, {:id => "1", :user => params}, { :user => users(:dennis), :account_id => "1" }
#    assert_redirected_to :controller => "users"
#    assert_equal "qwerty", User.find(1).first_name
  end
end

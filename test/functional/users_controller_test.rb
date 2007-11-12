require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  
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
  
  def test_index
    get :index, {:id => 1}, {:user => users(:dennis), :user_id => users(:dennis), :account_id => accounts(:dennis)}
    assert_response :success
  end
  
  def test_edit_user
    params = {:first_name => "qwerty", :last_name => "asdf", :email =>"asdf"}
    post :edit, {:id => 1, :user => params}, {:user => users(:dennis), :account_id => 1}
    assert_redirected_to :controller => "users"
    assert_equal "qwerty", User.find(1).first_name
  end
  
  def test_edit_user_unauthorized
    params = {:first_name => "qwerty", :last_name => "asdf", :email =>"asdf"}
    post :edit, {:id => 2, :user => params}, {:user => users(:dennis), :account_id => 1}
    assert_redirected_to "/index"
    assert_not_equal "qwerty", User.find(2).first_name
  end
    
  def test_get_user
    get :edit, {:id => 1}, {:user => users(:dennis), :user_id => users(:dennis).id, :account_id => users(:dennis).account_id}
    assert_response :success
    user = assigns(:user)
    assert_equal "dennis", user.first_name
  end
  
  def test_get_user_unauthorized
    get :edit, {:id => 2}, {:user => users(:dennis), :user_id => users(:dennis).id, :account_id => users(:dennis).account_id}
    assert_redirected_to "/index"
    assert_nil assigns(:user)
  end
  
  def test_short_password
    params = {:first_name => "qwerty", :last_name => "asdf", :email =>"asdf"}
    post :edit, {:id => 1, :user => params, :password_checkbox => "checked", :existing_password => "test"}, {:user => users(:dennis), :account_id => 1}
    assert_redirected_to :controller => "users", :action => "edit", :id => 1
    assert_equal flash[:message], "Your existing password must match what's currently stored in our system"
  end
end

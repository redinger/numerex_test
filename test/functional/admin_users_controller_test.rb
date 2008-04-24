require File.dirname(__FILE__) + '/../test_helper'
require 'admin/users_controller'

# Re-raise errors caught by the controller.
class Admin::UsersController; def rescue_action(e) raise e end; end

class Admin::UsersControllerTest < Test::Unit::TestCase
  
  fixtures :users, :accounts
  
  module RequestExtensions
    def server_name
      "helo"
    end
    def path_info
      "adsf"
    end
  end
  
  def setup
    @controller = Admin::UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end

  def test_index
    get :index, {}, get_user
    assert_response :success
  end
  
  def test_users_table
    get :index, {}, get_user
    assert_select "table.table tr", 8
  end
  
  def test_new_user
    get :new, {}, get_user
    assert_response :success
  end
  
  def test_create_user_without_email
    post :create, {:user => {:first_name => "dennis", :last_name => "baldwin", :password => "helloworld", :password_confirmation => "helloworld", :account_id => 1}}, get_user
    assert_redirected_to :action => "new"
    assert_equal flash[:error], "Email can't be blank<br />"
  end
  
  def test_create_user_with_short_password
    post :create, {:user => {:first_name => "dennis", :last_name => "baldwin", :email => "dennisb@ublip.com", :password => "hello", :password_confirmation => "hello", :account_id => 1}}, get_user
    assert_redirected_to :action => "new"
    assert_equal flash[:error], "Password is too short (minimum is 6 characters)<br />"
  end
  
  def test_create_user_duplicate_email
    post :create, {:user => {:first_name => "dennis", :last_name => "baldwin", :email => "dennis@ublip.com", :password => "helloworld", :password_confirmation => "helloworld", :account_id => 1}}, get_user
    assert_redirected_to :action => "new"
    assert_equal flash[:error], "Email has already been taken<br />"
  end
  
  def test_create_user
    post :create, {:user => {:first_name => "dennis", :last_name => "baldwin", :email => "dennisb@ublip.com", :password => "helloworld", :password_confirmation => "helloworld", :account_id => 1}}, get_user
    assert_redirected_to :action => "index"
    assert_equal flash[:message], "dennisb@ublip.com was created successfully"
  end

  def test_edit_account
    get :edit, {:id => 1}, get_user
    assert_response :success
  end
  
  def test_update_user
    post :update, {:id => 1, :user =>{:first_name => "dennis_new", :last_name => "baldwin_new", :email => "dennis@ublip.com", :account_id => 1}}, get_user
    assert_redirected_to :action => "index"
    assert_equal flash[:message], "dennis@ublip.com updated successfully"
  end
  
  def test_delete_user
    post :destroy, {:id => 1}, get_user
    assert_redirected_to :action => "index"
    assert_equal flash[:message], "dennis@ublip.com deleted successfully"
  end
  
  def get_user
    {:user => users(:dennis).id, :account_id => accounts(:dennis).id, :is_super_admin => users(:dennis).is_super_admin}
  end

end
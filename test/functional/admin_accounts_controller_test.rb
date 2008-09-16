require File.dirname(__FILE__) + '/../test_helper'
require 'admin/accounts_controller'

# Re-raise errors caught by the controller.
class Admin::AccountsController; def rescue_action(e) raise e end; end

class Admin::AccountsControllerTest < Test::Unit::TestCase
  
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
    @controller = Admin::AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end

  def test_index
    get :index, {}, get_user
    assert_response :success
  end
  
  def test_accounts_table
    get :index, {}, get_user
    assert_select "table tr", 7
  end
  
  def test_new_account
    get :new, {}, get_user
    assert_response :success
  end
  
  def test_create_account_without_subdomain
    post :create, {:account => {:company => "New Co", :zip => 12345}}, get_user
    assert_redirected_to :action => "new"
    assert_equal flash[:error], "Please specify a subdomain<br />"
  end
  
  def test_create_account_with_subdomain
    post :create, {:account => {:subdomain => "monkey", :company => "New Co", :zip => 12345}}, get_user
    assert_redirected_to :action => "index"
    assert_equal flash[:success], "monkey created successfully"
  end
  
  def test_edit_account
    get :edit, {:id => 4}, get_user
    assert_response :success
  end
  
  def test_update_account_without_zip
    post :update, {:id => 4, :account => {:subdomain => "newco", :company => "New Co"}}, get_user
    assert_redirected_to :action => "edit"
    assert_equal flash[:error], "Please specify your zip code<br />"
  end
  
  def test_update_account_with_zip
    post :update, {:id => 4, :account => {:subdomain => "newco", :company => "New Co", :zip => 12345}}, get_user
    assert_redirected_to :action => "index"
    assert_equal flash[:success], "newco updated successfully"
  end
  
  def test_delete_account
    post :destroy, {:id => 1}, get_user
    assert_redirected_to :action => "index"
    assert_equal flash[:success], "dennis deleted successfully"
  end
  
  def test_super_admin_can_access_across_subdomains
      get :subdomain_login, {:id=>4}, get_user
      assert_redirected_to("http://byron.ubliplocal.com:3000/login/admin_login")
  end

  def test_subdomain_login_account_not_present
      get :subdomain_login, {:id=>12545}, get_user
      assert_redirected_to :controller=>'/home', :action=>'index'
  end
  
  def test_standard_user_cannot_access_subdomain
      get :subdomain_login, {:id=>1}, get_standard_user
      assert_redirected_to :controller=>'/home'
  end
  
  def get_standard_user
     {:user => users(:demo).id, :account_id => users(:demo).id, :is_super_admin => users(:demo).is_super_admin} 
  end

  def get_user
    {:user => users(:dennis).id, :account_id => accounts(:dennis).id, :is_super_admin => users(:dennis).is_super_admin}
  end

end

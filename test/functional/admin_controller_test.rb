require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  
  fixtures :users, :accounts, :devices, :device_profiles
  
  module RequestExtensions
    def server_name
      "helo"
    end
    def path_info
      "adsf"
    end
  end
  
  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end

  def test_not_logged_in
    get :index
    assert_redirected_to :controller => "home"
  end
  
  def test_super_admin
    get :index, {}, {:user => users(:dennis).id, :account_id => accounts(:dennis).id, :is_super_admin => users(:dennis).is_super_admin}
    assert_response :success
  end
  
  def test_not_super_admin
    get :index, {}, {:user => users(:demo).id, :account_id => accounts(:dennis).id, :is_super_admin => users(:demo).is_super_admin} 
    assert_redirected_to :controller => "home"
  end
  
  def test_page_contents
    get :index, {}, {:user => users(:dennis).id, :account_id => accounts(:dennis).id, :is_super_admin => users(:dennis).is_super_admin}
    assert_select "ul.list li", 4 # Verify 3 elements in the list
    assert_select "ul.list li:first-child", :text => "6 active Accounts - view or create"
    assert_select "ul.list li:nth-child(2)", :text => "7 active Users - view or create"
    assert_select "ul.list li:nth-child(3)", :text => "7 active Devices - view or create"
    assert_select "ul.list li:last-child", :text => "1 active Device Profiles - view or create"
  end
end
require File.dirname(__FILE__) + '/../test_helper'
require 'admin/devices_controller'

# Re-raise errors caught by the controller.
class Admin::DevicesController; def rescue_action(e) raise e end; end

class Admin::DevicesControllerTest < Test::Unit::TestCase
  
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
    @controller = Admin::DevicesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end

  def test_index
    get :index, {}, get_user
    assert_response :success
  end
  
  def test_devices_table
    get :index, {}, get_user
    assert_select "table tr", 10
  end
  
  def test_new_device
    get :new, {}, get_user
    assert_response :success
  end
    
  def test_create_device_with_duplicate_imei
    post :create, {:id => 1, :device => {:imei => "1234", :account_id => 1}}, get_user
    assert_redirected_to :action => "new"
    assert_equal flash[:error], "Name can't be blank<br />Imei has already been taken<br />"
  end
  
  def test_update_device
    post :update, {:id => 1, :device => {:name => "my device", :imei => "1234", :provision_status_id => 1, :account_id => 1}}, get_user
    assert_redirected_to :action => "index"
    assert_equal flash[:success], "my device updated successfully"
  end
  
  def test_delete_device
    post :destroy, {:id => 1}, get_user
    assert_redirected_to :action => "index"
    assert_equal flash[:success], "device 1 deleted successfully"
  end

  def get_user
    {:user => users(:dennis).id, :account_id => accounts(:dennis).id, :is_super_admin => users(:dennis).is_super_admin}
  end

end

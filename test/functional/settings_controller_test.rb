require File.dirname(__FILE__) + '/../test_helper'
require 'settings_controller'

# Re-raise errors caught by the controller.
class SettingsController; def rescue_action(e) raise e end; end

class SettingsControllerTest < Test::Unit::TestCase
  
  fixtures :accounts, :users
  
  module RequestExtensions
    def server_name
      "yoohoodilly"
    end
    def path_info
      "asdf"
    end
  end
  
  def setup
    @controller = SettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end

  def test_index
    # Get the settings page
    get :index, {}, {:account_id => 1, :user_id => 1}
    assert_response :success
    account = assigns(:account)
    user = assigns(:user)
    assert_equal 'Dennis Co', account.company
    assert_equal 'Central Time (US & Canada)', user.time_zone
    assert_equal 1, user.enotify
    
    # Post the settings
    post :index, {:company => 'New Co', :notify => 1, :time_zone => 'Eastern Time (US & Canada)'}, {:account_id => 1, :user_id => 1}
    assert_redirected_to :controller => 'settings', :action => 'index'
    
    # Verify the settings were saved
    account = assigns(:account)
    user = assigns(:user)
    assert_equal 'New Co', account.company
    assert_equal 'Eastern Time (US & Canada)', user.time_zone
    assert_equal 1, user.enotify
    
    #post setting with group notification
    post :index, {:company => 'New Co', :notify => 2, :rad_grp1=>1, :time_zone => 'Eastern Time (US & Canada)'}, {:account_id => 1, :user_id => 1}
    assert_redirected_to :controller => 'settings', :action => 'index'
    
    account = assigns(:account)
    user = assigns(:user)
    assert_equal 'New Co', account.company
    assert_equal 'Eastern Time (US & Canada)', user.time_zone
    assert_equal 2, user.enotify
    
  end
  
  # Test that when a user selects "No Time Zone" that the value is set to NULL in the database (this impacts the notifier daemon)
  def test_no_time_zone
     get :index, {}, {:account_id => 1, :user_id => 1}
     post :index, {:company => 'New Co', :notify => 1, :time_zone => ''}, {:account_id => 1, :user_id => 1}
     user = assigns(:user)
     assert_equal nil, user.time_zone
  end
end

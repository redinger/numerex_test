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
    account = accounts(:dennis)
    user = users(:dennis)
    assert_equal 'Dennis Co', account.company
    assert_equal 'Central Time (US & Canada)', user.time_zone
    assert_equal true, user.enotify
    
    # Post the settings
    post :index, {:company => 'New Co', :notify => 1, :time_zone => 'Eastern Time (US & Canada)'}, {:account_id => 1, :user_id => 1}
    assert_redirected_to :controller => 'settings', :action => 'index'
    
    # Verify the settings were saved
    account = assigns(:account)
    user = assigns(:user)
    assert_equal 'New Co', account.company
    assert_equal 'Eastern Time (US & Canada)', user.time_zone
    assert_equal true, user.enotify
  end
end
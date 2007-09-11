require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  
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
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end

  # Replace this with your real tests.
  def test_index
    puts @request
    get :index, {}, { :user => users(:dennis).id, :account_id => accounts(:dennis).id} 
    assert_response :success
  end
  
  def test_index_not_admin
    puts @request
    assert_raises RuntimeError do
      get :index, {}, { :user => users(:nick).id, :account_id => accounts(:nick).id} 
    end
  end
end

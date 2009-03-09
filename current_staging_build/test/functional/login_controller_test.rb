require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  
  fixtures :users, :accounts
  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_index
    get :index
  end
  
  def test_login
   @request.host="dennis.ublip.com"
   post :index, {:email => users(:dennis).email, :password => "testing"} 
   assert_redirected_to :controller => "home", :action => "index"
   assert_equal accounts(:dennis).id, @request.session[:account_id]
   assert_equal users(:dennis).id, @request.session[:user_id]
   assert_equal users(:dennis).id, @request.session[:user]
   assert_equal users(:dennis).email, @request.session[:email]
   assert_equal users(:dennis).first_name, @request.session[:first_name]
   assert_equal users(:dennis).account.company, @request.session[:company]
 end
 
 def test_login_failure
   @request.host="dennis.ublip.com"
   post :index, {:email => users(:dennis).email, :password => "wrong"} 
   assert flash[:username]
   assert_redirected_to "/login"
 end
 
 def test_logout
   get :logout
   assert_redirected_to "/login"
 end
 
 def test_change_password
    post :password, {:id => "1", :user => {:password => "newpassword", :password_confirmation =>"newpassword"}}
    user2 = User.find(1)
    assert_equal User.encrypt("newpassword", "salty"), user2.crypted_password
 end

 def test_admin_login
     @request.host="byron.ublip.com"
     @request.cookies['account_value'] = CGI::Cookie.new('account_value', '4')
     @request.cookies['admin_user_id'] = CGI::Cookie.new('admin_user_id', '1')     
     get :admin_login,{}
     assert_redirected_to(:controller => '/home', :action => 'index')
     assert_equal "dennis@ublip.com",@request.session[:user].email
     assert_equal 4, @request.session[:account_id]
     assert_equal 1, @request.session[:user_id]          
     assert_equal "dennis", @request.session[:first_name]
     assert_equal "Byron Co", @request.session[:company] 
 end

 def test_admin_login_with_invalid_account_number
     @request.cookies['account_value'] = CGI::Cookie.new('account_value', '12563')
     get :admin_login,{}
     assert_redirected_to(:controller => 'login')
 end

 def test_admin_login_with_null_account
     @request.cookies['account_value'] = CGI::Cookie.new('account_value', nil)
     get :admin_login,{}
     assert_redirected_to(:controller => 'login')
 end
 
end

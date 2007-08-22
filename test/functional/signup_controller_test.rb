require File.dirname(__FILE__) + '/../test_helper'
require 'signup_controller'

# Re-raise errors caught by the controller.
class SignupController; def rescue_action(e) raise e end; end

class SignupControllerTest < Test::Unit::TestCase
  
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
    @controller = SignupController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end
  
  # Test for signup process which includes creating user, account, and registration email
  def test_signup
    post :create, :user => {:first_name => 'spongebob', :last_name => 'squarepants', :password => 'testing', :password_confirmation => 'testing', :email => 'spongebob@bikinibottom.org'},
      :account => {:subdomain => 'bikinibottom.org', :zip => '99999', :company => 'Krusty Krab Restaurant'}
    
    key = Mailer.get_last_key
    assert_not_nil key
    assert_nil (flash[:message])
    
    user =  User.find(:first, :conditions => 'first_name="spongebob"')
    assert_not_nil user
    assert_not_nil user.account
    assert_equal 'spongebob', user.first_name
    assert_equal 'squarepants', user.last_name
    assert_equal 'spongebob@bikinibottom.org', user.email
    assert_equal 'Krusty Krab Restaurant', user.account.company
    assert_equal false, user.account.is_verified
    
    puts "user:" + user.id.to_s
    get :verify, {:id => user.id, :key => key}
    user.reload
    assert_equal true, user.account.is_verified
    
  end
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

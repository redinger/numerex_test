require File.dirname(__FILE__) + '/../test_helper'
require 'readings_controller'

# Re-raise errors caught by the controller.
class ReadingsController; def rescue_action(e) raise e end; end

class ReadingsControllerTest < Test::Unit::TestCase
  
  fixtures :users,:accounts,:readings,:devices
  
  def setup
    @controller = ReadingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_recent
    get :recent, {}, {:user=>users(:dennis), :account_id => accounts(:dennis).id}
    assert_response :success
  end

  def test_last
    @request.host="dennis.ublip.com"
    @request.env["Authorization"] = "Basic " + Base64.encode64("dennis@ublip.com:testing")
    get :last, { :id => "1"}, {:user => users(:dennis), :user_id => users(:dennis), :account_id => accounts(:dennis)}
    
    assert_select "channel>item" do |element|
       assert_tag :tag => "georss:point", :content => "32.6358 -97.1757"
    end
  end
  
  def test_all
    @request.host = "dennis.ublip.com"
     @request.env["Authorization"] = "Basic " + Base64.encode64("dennis@ublip.com:testing")
     get :all, {}, {:user => users(:dennis), :user_id => users(:dennis), :account_id => accounts(:dennis)}
     # Simple test to validate there are 5 items in the georss response
     assert_select "channel item", 4
  end
  
  def test_last_not_auth
    @request.host="dennis.ublip.com"
    @request.env["Authorization"] = "Basic " + Base64.encode64("dennis@ublip.com:testing")
    get :last, { :id => 7}, {:user => users(:dennis), :user_id => users(:dennis), :account_id => accounts(:dennis)}
    puts @response.body
    
    assert_select "channel" do |element|
    element[0].children.each do |tag|
           if tag.class==HTML::Tag && tag.name=="item"
             fail("should not return any content")
           end
    end
      
    end
  end
  
  # Make sure that we're requiring HTTP auth
  def test_require_http_auth_for_last
    @request.host="dennis.ublip.com"
    get :last, {:id => 1}, {:user => users(:dennis), :user_id => users(:dennis), :account_id => accounts(:dennis)}
    assert_equal @response.body, "Couldn't authenticate you"
  end  
  
  # Make sure that we're requiring HTTP auth
  def test_require_http_auth_for_all
    @request.host="dennis.ublip.com"
    get :all, {}, {:user => users(:dennis), :user_id => users(:dennis), :account_id => accounts(:dennis)}
    assert_equal @response.body, "Couldn't authenticate you"
  end
  
  # Test public feed
  def test_public_feed
    @request.host = "dennis.ublip.com"
    get :public
    assert_select "channel item", 1
  end
  
end

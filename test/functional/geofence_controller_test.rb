require File.dirname(__FILE__) + '/../test_helper'
require 'geofence_controller'

# Re-raise errors caught by the controller.
class GeofenceController; def rescue_action(e) raise e end; end

class GeofenceControllerTest < Test::Unit::TestCase
  
  fixtures :devices, :users, :accounts, :geofences
  
  def setup
    @controller = GeofenceController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    def @request.server_name
      {}
    end
    
    def @request.path_info
      ""
    end 
  
  end
  
  def test_index
    get :index, {}, { :user => users(:dennis), :account_id => "1" }
    assert_not_nil assigns("geofences")
  end
  
  def test_detail
    get :detail, {:id => "1"}, { :user => users(:dennis), :account_id => "1" }
    assert_not_nil assigns("geofence")
  end

  def test_view
    get :view, {:id => "account1"}, { :user => users(:dennis), :account_id => "1" }
    assert_not_nil assigns("account")
    
    get :view, {:id => "device1"}, { :user => users(:dennis), :account_id => "1" }
    assert_not_nil assigns("device")
    
    get :view, {:id => "1"}, { :user => users(:dennis), :account_id => "1" }
    assert_not_nil assigns("device")
  end
  
  def test_new
    post :new, {:id => "1", :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_equal flash[:message] , 'Geofence created succesfully'
  end
  
  def test_create
    #apparent bug in rail makes flash go away after first post in this test
    post :new, {:id => "1", :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "index" 
    assert_equal( "Geofence created succesfully", @response.flash[:message] )
    #assert_equal 1, devices(:device1).geofences[0].radius
    #assert_equal 1, devices(:device1).geofences[0].latitude
    #assert_equal 1, devices(:device1).geofences[0].longitude
    
    post :new, {:id => "1", :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "index" 

    post :new, {:id => "1", :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "index" 
    
    post :new, {:id => "1", :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "index" 
    
    post :new, {:id => "1", :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "index" 
  end
  
  def test_delete
    post :delete, {:id => '1', :device_id => '1'}, { :user => users(:dennis), :account_id => "1" }
    assert_equal "Geofence deleted successfully", flash[:message]
    assert_redirected_to :controller => "geofence", :action => "index"
  end
  
  def test_edit
    post :edit, {:device_id => '1', :id => '1', :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_equal flash[:message] , 'Geofence updated succesfully'
    assert_redirected_to :controller => "geofence", :action => "index"
  end
  
end

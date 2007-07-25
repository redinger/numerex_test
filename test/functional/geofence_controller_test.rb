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
  end
  
  def test_create
    #apparent bug in rail makes flash go away after first post in this test
    post :add, {:id => "1", :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "view" 
    assert_flash_equal "Geofence created succesfully", :message
    
    post :add, {:id => "1", :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "view" 

    post :add, {:id => "1", :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "view" 
    
     post :add, {:id => "1", :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "view" 
    
     post :add, {:id => "1", :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "view" 
  end
  
  def test_delete
    post :delete, {:geofence_id => '1', :device_id => '1'}, { :user => users(:dennis), :account_id => "1" }
  end
  
  def test_edit
     post :edit, {:device_id => '1', :geofence_id => '1', :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
  end
  
end

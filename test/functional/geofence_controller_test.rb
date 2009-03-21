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
  
  def test_index_with_empty_device_dis
      get :index,{},{ :user => users(:ken), :account_id => "3" }
      assert_response :success
  end
  
  def test_detail
    get :detail, {:id => "1"}, { :user => users(:dennis), :account_id => "1" }
    assert_not_nil assigns("geofence")
  end

   def test_detail_for_invalid_geofence_id
    get :detail, {:id => "5"}, { :user => users(:dennis), :account_id => "1" }
    assert_response 302
    assert_equal flash[:error], "Invalid action."
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
    post :new, {:id => "1", :ref_url => '/geofence', :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_equal flash[:success] , "qwerty created succesfully"
  end
  
  def test_invalid_device
     post :new, {:id => "1", :ref_url => '/geofence', :name =>"", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
     assert_equal flash[:error], "Location not created"      
  end
  
  def test_create
    #apparent bug in rail makes flash go away after first post in this test
    post :new, {:id => "1", :ref_url => '/geofence', :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "index" 
    assert_equal( "qwerty created succesfully", @response.flash[:success] )
    #assert_equal 1, devices(:device1).geofences[0].radius
    #assert_equal 1, devices(:device1).geofences[0].latitude
    #assert_equal 1, devices(:device1).geofences[0].longitude
    
    post :new, {:id => "1", :ref_url => '/geofence', :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "index" 

    post :new, {:id => "1", :ref_url => '/geofence', :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "index" 
    
    post :new, {:id => "1", :ref_url => '/geofence', :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "index" 
    
    post :new, {:id => "1", :ref_url => '/geofence', :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave"}, { :user => users(:dennis), :account_id => "1" }
    assert_redirected_to :controller => "geofence", :action => "index" 
  end
  
  def test_delete
    get :delete, {:id => '1', :device_id => '1'}, { :user => users(:dennis), :account_id => "1" }
    assert_equal "home deleted successfully", flash[:success]
    assert_redirected_to :controller => "geofence", :action => "index"
  end
  
  def test_delete_geofence_by_invalid_user
    get :delete, {:id => '1'}, { :user => users(:ken), :account_id => "3" }
    assert_equal "Invalid action.", flash[:error]
    assert_redirected_to :controller => "geofence", :action => "index"    
  end
  
  def delete_unknown_geofence
    get :delete, {:id => '17521'}, { :user => users(:dennis), :account_id => "1" }
    assert_equal "Invalid action.", flash[:error]
    assert_redirected_to :controller => "geofence", :action => "index"        
  end
  
  def test_for_device_id_for_delete
    get :delete, {:id => '3'}, { :user => users(:dennis), :account_id => "1" }
    assert_equal "work deleted successfully", flash[:success]
    assert_redirected_to :controller => "geofence", :action => "index"
  end
  
  def test_edit
    post :edit, {:device_id => '1', :id => '1', :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave", :ref_url=>"/geofence/index"}, { :user => users(:dennis), :account_id => "1" }
    assert_equal flash[:success] , 'qwerty updated succesfully'
    assert_redirected_to :controller => "geofence", :action => "index"
  end
  
  def test_edit_invalid_geofence
      post :edit, {:device_id => '1', :id => '1', :name => "", :bounds=>"1,1,1", :address=>"1600 Penn Ave", :ref_url=>"/geofence/index"}, { :user => users(:dennis), :account_id => "1" }
      assert flash[:error] 
  end
  
  def test_edit_for_invalid_geofence
      get :edit, {:id=>'5'}, { :user => users(:dennis), :account_id => "1" }
      assert_response 302
      assert_equal flash[:error], "Invalid action."
  end
  
  def test_edit_unautharized_geofence      
      post :edit, {:device_id => '1', :id => '1', :name => "", :bounds=>"1,1,1", :address=>"1600 Penn Ave", :ref_url=>"/geofence/index"}, { :user => users(:ken), :account_id => "3" }
      assert_equal "Invalid action.", flash[:error]      
  end
  
  #check for nil in device_id column if device_id and account_id both in the db as true value while editing for old geofences
  def test_check_for_nil_in_device_id_column
     get :edit, {:id => '1'},  { :user => users(:dennis), :account_id => "1" }          
     geofence = assigns("geofence")
     assert_equal geofence.device_id, 1
     assert_equal geofence.account_id, 1
  end

  def  test_after_edit_check_nil_for_device_id
      post :edit, {:id=>'1', :device=>'1', :radio=>'2',:account_id=>'1', :name => "qwerty", :bounds=>"1,1,1", :address=>"1600 Penn Ave", :ref_url=>"/geofence/index"}, { :user => users(:dennis), :account_id => "1" }      
      assert_equal 1,Geofence.find(1).device_id
      assert_equal 0,Geofence.find(1).account_id
  end
  
  
  def test_view_gf_is_true_for_device
     get :view, {:id=>"device1", :gf=>'1'}, { :user => users(:dennis), :account_id => "1" }
     assert_response :success        
  end
  
  def test_view_for_only_device_id
     get :view, {:id=>'1'}, { :user => users(:dennis), :account_id => "1" }
     assert_response :success            
  end
  
  def test_view_for_invalid_device_id
     get :view, {:id=>'456'}, { :user => users(:dennis), :account_id => "1" }     
     assert_response 302                
     assert_equal flash[:error], "Invalid action."
  end
  
  def test_view_for_invalid_gf_for_device_level
     get :view, {:id=>"device8", :gf=>'5'}, { :user => users(:dennis), :account_id => "1" }
     assert_response 302
     assert_equal flash[:error], "Invalid action"
  end
    
  def test_view_gf_is_true_for_account
      get :view, {:id=>"account1", :gf=>'20'}, { :user => users(:dennis), :account_id => "1" }
      assert_response :success
  end    
  
  def test_view_detail
      get :view_detail, {:id=>"1"}, { :user => users(:dennis), :account_id => "1" }
      assert_response :success
  end
  
  def test_delete_unautharized      
      post :delete, {:id => '2', :device_id => '1'}, { :user => users(:ken), :account_id => "3" }
      assert_equal 'Invalid action.',flash[:error]
  end
    
end

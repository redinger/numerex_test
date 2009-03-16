require File.dirname(__FILE__) + '/../test_helper'
require 'reports_controller'

# Re-raise errors caught by the controller.
class ReportsController; def rescue_action(e) raise e end; end

class ReportsControllerTest < Test::Unit::TestCase
  
  module RequestExtensions
    def server_name
      "yoohoodilly"
    end
    def path_info
      "asdf"
    end
  end
  
  fixtures :users, :readings, :stop_events, :idle_events, :runtime_events, :device_profiles
  
  def setup
    @controller = ReportsController.new
    @request    = ActionController::TestRequest.new 
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end
  
  # Test all readings report
  def test_all
    # Device 1, page 1
    get :all, {:id => 1}, {:user => users(:dennis), :account_id => 1}
    assert_response :success
    readings = assigns(:readings)
#    assert_equal "6762 Big Springs Dr, Arlington, TX", readings[0].short_address
#    assert_equal 29, readings[0].speed
    
    # Device 1, page 2
    # Need to figure out how to manage the ResultCount mock being set at 5
  end
  
  def test_all_for_start_and_end_time
      get :all, {:id => 1, :start_date=>"2008-07-18",:end_date=>"2004-07-18"}, {:user => users(:dennis), :account_id => 1}
      assert_response :success
  end
  
   
  def test_all_for_start_and_end_time_page_number
      get :all, {:id => 1, :start_date=>"2008-07-18", :end_date=>"2004-07-18", :page=>3}, {:user => users(:dennis), :account_id => 1}
      assert_response :success
  end

  def test_index
     get :index, {:id => 1}, {:user => users(:dennis), :account_id => 1}
     assert_response :success
  end
  
  def test_index_for_gmap_session_to_all
    get :index, {}, { :user => users(:dennis), :account_id => 1},{:gmap_value=>"all"}     
    assert_response :success            
   end    
   
   def test_index_for_gmap_session_to_default
        get :index, {}, { :user => users(:dennis), :account_id => 1},{:gmap_value=>"default"}     
        assert_response :success            
   end    

   def test_index_for_gmap_session_to_group_number
        get :index, {}, { :user => users(:dennis), :account_id => 1},{:gmap_value=>1}     
        assert_response :success            
   end
   
   def test_index_with_group_selection
     get :index, {:group_id => 1}, {:user => users(:dennis), :account_id => 1}
     devices = assigns(:devices)
     assert_equal 2, devices.size
   end

  # Need to extend the following reports with tests that actually verify page content
  def test_idle
    get :idle, {:id => 1}, {:user => users(:dennis), :account_id => 1}
    assert_response :success
  end
  
  def test_runtime
    get :runtime, {:id => 1}, {:user => users(:dennis), :account_id => 1}
    assert_response :success
  end   
  
  def test_gpio1
    get :gpio1, {:id => 1}, {:user => users(:dennis), :account_id => 1}
    assert_response :success
  end
  
  def test_gpio2
    get :gpio2, {:id => 1}, {:user => users(:dennis), :account_id => 1}
    assert_response :success
  end

  def test_all_unauthorized
    get :all, {:id => 1}, {:user => users(:nick)}
    assert_nil assigns(:readings)
    assert_redirected_to "/index"
  end
  
  def test_stop_unauthorized
    pretend_now_is(Time.at(1185490000)) do
      puts "now is:" + Time.now.to_s
      get :stop, {:id=>"3", :t=>"1"}, { :user => users(:nick), :account_id => users(:nick).account_id } 
      assert_nil assigns(:stops)
      assert_redirected_to "/index"
    end
  end

  # Test stop report
  def test_stop
    get :stop, {:id => 1, :start_date=>{"month"=>"4", "day"=>"27", "year"=>"2007"}, :end_date=>{"month"=>"7", "day"=>"1", "year"=>"2008"}}, {:user => users(:dennis), :account_id => users(:dennis).account_id}
    assert_equal 5, assigns(:record_count)
    assert_response :success
=begin
    pretend_now_is(Time.at(1185490000)) do
      puts "now is:" + Time.now.to_s
      get :stop, {:id=>"1", :t=>"1", :start_time1=>"Thu May 24 21:24:10 +0530 2004",:end_time1=>"Thu Jun 25 21:24:10 +0530 2008"}, {:user => users(:dennis), :account_id => users(:dennis).account_id } 
      stops = assigns(:stops)
      assert_equal 8, assigns(:record_count)
      assert_response :success
      assert_template "stop"

      assert_equal 5, stops.size
      
      assert_equal -1, stops[0].duration
      assert_equal Time.local(2007, "Jul", 26, 16, 55, 0), stops[0].created_at
      
      assert_nil stops[1].duration
      assert_equal Time.local(2007, "Jul", 26, 16, 00, 0), stops[1].created_at
      
      assert_equal 3480, stops[2].duration
      assert_equal Time.local(2007, "Jul", 26, 15, 0, 0), stops[2].created_at
      
      assert_equal 780, stops[3].duration
      assert_equal Time.local(2007, "Jul", 26, 14, 48, 39), stops[3].created_at
      
      assert_equal Time.local(2007, "Jul", 26, 14, 37, 39), stops[4].created_at
      assert_equal -1720.0, stops[4].duration
      
     
      
      get :stop, {:id=>"3", :t=>"1", :p => "2", :start_time1=>"Thu May 24 21:24:10 +0530 2004",:end_time1=>"Thu Jun 25 21:24:10 +0530 2008"}, { :user => users(:dennis), :account_id => users(:dennis).account_id }
      stops = assigns(:stops)
      
      assert_equal 5, stops.size
      
      assert_equal -1, stops[0].duration
      assert_equal Time.local(2007, "Jul", 26, 16, 55, 00), stops[0].created_at
      assert_equal nil, stops[1].duration
      assert_equal Time.local(2007, "Jul", 26, 16, 00, 00), stops[1].created_at
      
      assert_equal 3480.0, stops[2].duration
      assert_equal Time.local(2007, "Jul", 26, 15, 00, 00), stops[2].created_at
      
    end

=end
  end
  
  # Test geofence report
  def test_geofence
    get :geofence, {:id => '1', :start_date=>{"month"=>"4", "day"=>"27", "year"=>"2007"}, :end_date=>{"month"=>"7", "day"=>"1", "year"=>"2008"}}, {:user => users(:dennis), :account_id => users(:dennis).account_id}
    assert_response :success
    readings = assigns(:readings)
#    assert_equal "Yates Dr, Hurst, TX", readings[1].short_address
    assert_equal 0, readings[1].speed
#    assert_equal "exitgeofen_et51", readings[1].event_type
  end
  
  def test_geofence_unauthorized
    get :geofence, {:id => 1, :t => 30}, {:user => users(:nick)}
    assert_redirected_to "/index"
    assert_nil assigns(:readings)
  end
 
 def test_for_valid_time
    get :all, {:id => 1, :t => 30, :start_date=>{"month"=>"4", "day"=>"27", "year"=>"2008"}, :end_date=>{"month"=>"6", "day"=>"26", "year"=>"2008"}}, {:user => users(:dennis), :account_id => users(:dennis).account_id}
    assert_response :success    
 end    
  
  # Report exports.  Needs support for readings, stops, and geofence exports
  def test_export
    get :export, {:id => 6, :type => 'all', :start_date=>"2008-05-24", :end_date=>"2008-06-26"}, {:user => users(:dennis), :account_id => users(:dennis).account_id}
    assert_response :success
    assert_kind_of String, @response.body
    output = StringIO.new
    #assert_nothing_raised { @response.body.call(@response, output) }
    #assert_equal csv_data, output.string
    # for stop events
    get :export, {:id => 6, :type => 'stop', :start_date=>"2008-05-24", :end_date=>"2008-06-25"}, {:user => users(:dennis), :account_id => users(:dennis).account_id}    
    assert_response :success
    # for geofence 
    get :export, {:id => 6, :type => 'geofence', :start_date=>"2008-05-24", :end_date=>"2008-06-25"}, {:user => users(:dennis), :account_id => users(:dennis).account_id}    
    assert_response :success
    
    get :export, {:id => 6, :type => 'idle', :start_date=>"2008-05-24", :end_date=>"2008-06-25"}, {:user => users(:dennis), :account_id => users(:dennis).account_id}    
    assert_response :success

    get :export, {:id => 6, :type => 'runtime', :start_date=>"2008-05-24", :end_date=>"2008-06-25"}, {:user => users(:dennis), :account_id => users(:dennis).account_id}    
    assert_response :success
   
   
  end
  
  private
  def csv_data
    reading1 = readings(:reading24)
    reading2 = readings(:reading26)
    "latitude,longitude,address,speed,direction,altitude,event_type,note,when\r\n#{reading1.latitude},#{reading1.longitude},\"#{reading1.short_address}\",#{reading1.speed},#{reading1.direction},#{reading1.altitude},#{reading1.event_type},#{reading1.note},#{reading1.created_at}\r\n#{reading2.latitude},#{reading2.longitude},\"#{reading2.short_address}\",#{reading2.speed},#{reading2.direction},#{reading2.altitude},#{reading2.event_type},#{reading2.note},#{reading2.created_at}\r\n"
  end
end

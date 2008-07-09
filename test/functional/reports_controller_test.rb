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
  
  fixtures :users, :readings, :stop_events
  
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
    assert_equal "6762 Big Springs Dr, Arlington, Texas", readings[0].shortAddress
    assert_equal 29, readings[0].speed
    
    # Device 1, page 2
    # Need to figure out how to manage the ResultCount mock being set at 5
  end
  
  def test_all_for_start_and_end_time
      get :all, {:id => 1, :start_time1=>"Thu May 24 21:24:10 +0530 2004",:end_time1=>"Thu Jun 25 21:24:10 +0530 2008"}, {:user => users(:dennis), :account_id => 1}
      assert_response :success
  end
  
  def test_all_for_start_and_end_time_page_number
      get :all, {:id => 1, :start_time1=>"Thu May 24 21:24:10 +0530 2004",:end_time1=>"Thu Jun 25 21:24:10 +0530 2008", :page=>3}, {:user => users(:dennis), :account_id => 1}
      assert_response :success
  end
  
  def test_index
     get :index, {:id => 1}, {:user => users(:dennis), :account_id => 1}   
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
    get :stop, {:id => 1, :start_time1=>{"month"=>"4", "day"=>"27", "year"=>"2007"}, :end_time1=>{"month"=>"7", "day"=>"1", "year"=>"2008"}}, {:user => users(:dennis), :account_id => users(:dennis).account_id}
    assert_response :success
    assert_equal 5, assigns(:record_count)
    stop_events = assigns(:stop_events)
    assert_equal stop_events[0].duration, nil
    assert_equal stop_events[1].duration, 676
    assert_equal stop_events[2].duration, 73
    
    get :stop, {:id => 2, :start_time1=>{"month"=>"7", "day"=>"1", "year"=>"2008"}, :end_time1=>{"month"=>"7", "day"=>"9", "year"=>"2008"}}, {:user => users(:dennis), :account_id => users(:dennis).account_id}
    assert_response :success
    assert_equal 1, assigns(:record_count)
    assert_equal stop_events[0].duration, nil
  end
  
  # Test geofence report
  def test_geofence
    get :geofence, {:id => 1, :t => 30}, {:user => users(:dennis), :account_id => users(:dennis).account_id}
    assert_response :success
    readings = assigns(:readings)
    assert_equal "Yates Dr, Hurst, Texas", readings[1].shortAddress
    assert_equal 0, readings[1].speed
    assert_equal "exitgeofen_et51", readings[1].event_type
  end
  
  def test_geofence_unauthorized
    get :geofence, {:id => 1, :t => 30}, {:user => users(:nick)}
    assert_redirected_to "/index"
    assert_nil assigns(:readings)
  end
 
 def test_for_valid_time
    get :all, {:id => 1, :t => 30, :start_time1=>{"month"=>"4", "day"=>"27", "year"=>"2008"}, :end_time1=>{"month"=>"6", "day"=>"26", "year"=>"2008"}}, {:user => users(:dennis), :account_id => users(:dennis).account_id}
    assert_response :success    
 end    
  
  # Report exports.  Needs support for readings, stops, and geofence exports
  def test_export
    get :export, {:id => 6, :type => 'all', :start_time=>"Thu May 24 21:24:10 +0530 2008", :end_time=>"Thu Jun 26 21:24:10 +0530 2008"}, {:user => users(:dennis), :account_id => users(:dennis).account_id}
    assert_response :success
    assert_kind_of Proc, @response.body
    output = StringIO.new
    assert_nothing_raised { @response.body.call(@response, output) }
    #assert_equal csv_data, output.string
    # for stop events
    get :export, {:id => 6, :type => 'stop', :start_time=>"Thu May 24 21:24:10 +0530 2008", :end_time=>"Thu Jun 25 21:24:10 +0530 2008"}, {:user => users(:dennis), :account_id => users(:dennis).account_id}    
    assert_response :success
    # for geofence 
    get :export, {:id => 6, :type => 'geofence', :start_time=>"Thu May 24 21:24:10 +0530 2008", :end_time=>"Thu Jun 25 21:24:10 +0530 2008"}, {:user => users(:dennis), :account_id => users(:dennis).account_id}    
    assert_response :success
  end
  
  private
  def csv_data
    reading1 = readings(:reading24)
    reading2 = readings(:reading26)
    "latitude,longitude,address,speed,direction,altitude,event_type,note,when\r\n#{reading1.latitude},#{reading1.longitude},\"#{reading1.shortAddress}\",#{reading1.speed},#{reading1.direction},#{reading1.altitude},#{reading1.event_type},#{reading1.note},#{reading1.created_at}\r\n#{reading2.latitude},#{reading2.longitude},\"#{reading2.shortAddress}\",#{reading2.speed},#{reading2.direction},#{reading2.altitude},#{reading2.event_type},#{reading2.note},#{reading2.created_at}\r\n"
  end
end

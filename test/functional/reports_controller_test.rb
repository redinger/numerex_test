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
  
  fixtures :users, :readings
  
  def setup
    @controller = ReportsController.new
    @request    = ActionController::TestRequest.new 
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end
  
  # Test all readings report
  def test_all
    # Device 1, page 1
    get :all, {:id => 1}, {:user => users(:dennis)}
    assert_response :success
    readings = assigns(:readings)
    assert_equal "6762 Big Springs Dr, Arlington, Texas", readings[0].shortAddress
    assert_equal 29, readings[0].speed
    
    # Device 1, page 2
    # Need to figure out how to manage the ResultCount mock being set at 5
  end

  # Test stop report
  def test_stop
    pretend_now_is(Time.at(1185490000)) do
      puts "now is:" + Time.now.to_s
      get :stop, {:id=>"3", :t=>"1"}, { :user => users(:dennis) } 
      stops = assigns(:stops)
      assert_equal 7, assigns(:record_count)
      assert_response :success
      assert_template "stop"
      
      assert_equal 5, stops.size
      
      assert_equal 780, stops[0].duration
      assert_equal Time.local(2007, "Jul", 26, 14, 15, 59), stops[0].created_at
      
      assert_equal 280, stops[1].duration
      assert_equal Time.local(2007, "Jul", 26, 14, 27, 39), stops[1].created_at
      
      assert_equal 480, stops[2].duration
      assert_equal Time.local(2007, "Jul", 26, 14, 30, 59), stops[2].created_at
      
      assert_equal 780, stops[3].duration
      assert_equal Time.local(2007, "Jul", 26, 14, 37, 39), stops[3].created_at
      
      assert_equal 780, stops[4].duration
      assert_equal Time.local(2007, "Jul", 26, 14, 48, 39), stops[4].created_at
      
      get :stop, {:id=>"3", :t=>"1", :p => "2"}, { :user => users(:dennis) }
      stops = assigns(:stops)
      assert_equal 2, stops.size
      
      assert_equal 3480, stops[0].duration
      assert_equal Time.local(2007, "Jul", 26, 15, 0, 0), stops[0].created_at
      
      assert_equal -1, stops[1].duration
      assert_equal Time.local(2007, "Jul", 26, 16, 55, 0), stops[1].created_at
    end
  end
  
  # Test geofence report
  def test_geofence
    get :geofence, {:id => 1, :t => 30}, {:user => users(:dennis)}
    assert_response :success
    readings = assigns(:readings)
    assert_equal "Yates Dr, Hurst, Texas", readings[0].shortAddress
    assert_equal 0, readings[0].speed
    assert_equal "exitgeofen_et51", readings[0].event_type
  end
  
  # Report exports.  Needs support for readings, stops, and geofence exports
  def test_export
    get :export, {:id => 6, :type => 'all'}, {:user => users(:dennis)}
    assert_response :success
    assert_kind_of Proc, @response.body
    output = StringIO.new
    assert_nothing_raised { @response.body.call(@response, output) }
    assert_equal csv_data, output.string
  end
  
  private
  def csv_data
    reading1 = readings(:reading24)
    reading2 = readings(:reading26)
    "latitude,longitude,address,speed,direction,altitude,event_type,note,when\r\n#{reading1.latitude},#{reading1.longitude},\"#{reading1.shortAddress}\",#{reading1.speed},#{reading1.direction},#{reading1.altitude},#{reading1.event_type},#{reading1.note},#{reading1.created_at}\r\n#{reading2.latitude},#{reading2.longitude},\"#{reading2.shortAddress}\",#{reading2.speed},#{reading2.direction},#{reading2.altitude},#{reading2.event_type},#{reading2.note},#{reading2.created_at}\r\n"
  end
end

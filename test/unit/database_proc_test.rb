require File.dirname(__FILE__) + '/../test_helper'

class DatabaseProcTest < Test::Unit::TestCase
  
  fixtures :devices, :stop_events
  
  def setup
    file = File.new("db_procs.sql")
    file.readline
    file.readline  #skip 1st two lines of file
    sql = file.read
    sql.strip!
    statements = sql.split(';;')
    
    statements.each  {|stmt| 
          puts stmt
          ActiveRecord::Base.connection.execute(stmt)
    }
  end
  
  def test_stop_insert
    StopEvent.delete_all
    now = Time.now
    insert_stop(1.2,2.3, now, devices(:device1).imei)
    stops = StopEvent.find(:all)
    assert_equal(1, stops.size, "should have been one stop")
    
    insert_stop(1.2, 2.3, now+60, devices(:device1).imei)
    stops = StopEvent.find(:all)
    assert_equal(1, stops.size, "should have ignored duplicate stop")
    
    insert_stop(1.2, 2.3, now, devices(:device1).imei)
    stops = StopEvent.find(:all)
    assert_equal(1, stops.size, "should have ignored duplicate stop w/same timestamp")
    
    insert_stop(2.2, 2.3, now+70, devices(:device1).imei)
    stops = StopEvent.find(:all)
    assert_equal(2, stops.size, "should have allowed far away duplicate stop")
    
    insert_stop(2.2, 2.3, now+80, devices(:device2).imei)
    stops = StopEvent.find(:all)
    assert_equal(3, stops.size, "should have allowed stop on different device")
    
    insert_stop(2.2,2.3, now-200, devices(:device1).imei)
    stops = StopEvent.find(:all)
    assert_equal(4, stops.size, "should allowed stop in the past")
  end
  
  def test_process_stops
        Reading.delete_all
        assert_equal 20, stop_events(:one).duration
        assert_nil stop_events(:two).duration
        assert_nil stop_events(:three).duration
        assert_nil stop_events(:four).duration
          
        Reading.new(:latitude => "4.5", :longitude => "5.6", :device_id => devices(:device1).id, :created_at => "2008-07-01 15:20:00", :speed => 10).save
        Reading.new(:latitude => "8.5", :longitude => "5.614", :device_id => devices(:device1).id, :created_at => "2008-07-01 16:25:00", :speed => 10).save
        ActiveRecord::Base.connection.execute("call process_stop_events()")
        
        stop_events(:two).reload
        stop_events(:three).reload
        stop_events(:four).reload
        
        assert_equal 20, stop_events(:one).duration
        assert_equal 20, stop_events(:two).duration
        assert_equal 25, stop_events(:three).duration
        assert_nil stop_events(:four).duration
        
  end
  
  def insert_stop(lat, lng, created, imei)
    ActiveRecord::Base.connection.execute("CALL insert_stop_event(#{lat},#{lng},'#{imei}','#{created.strftime("%Y-%m-%d %H:%M:%S")}', 42)")
  end
  
  end
require File.dirname(__FILE__) + '/../test_helper'

class DatabaseProcTest < Test::Unit::TestCase
  
  fixtures :devices, :stop_events, :idle_events, :runtime_events
  
  def setup
    file = File.new("db_procs.sql")
    file.readline
    file.readline  #skip 1st two lines of file
    sql = file.read
    sql.strip!
    statements = sql.split(';;')
    
    statements.each  {|stmt| 
      ActiveRecord::Base.connection.execute(stmt)
      puts stmt
    }
    setup_fixtures
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
  
  def test_idle_insert
    IdleEvent.delete_all
    now = Time.now
    insert_idle(1.2,2.3, now, devices(:device1).imei)
    idle_events = IdleEvent.find :all
    assert_equal(1, idle_events.size, "should have been one idle event")
    
    insert_idle(1.2, 2.3, now+60, devices(:device1).imei)
    idle_events = IdleEvent.find :all
    assert_equal(1, idle_events.size, "should have ignored duplicate idle event")
    
    insert_idle(1.2, 2.3, now, devices(:device1).imei)
    idle_events = IdleEvent.find :all
    assert_equal(1, idle_events.size, "should have ignored duplicate idle event w/same timestamp")
    
    insert_idle(2.2, 2.3, now+70, devices(:device1).imei)
    idle_events = IdleEvent.find :all
    assert_equal(2, idle_events.size, "should have allowed far away duplicate idle event")
    
    insert_idle(2.2, 2.3, now+80, devices(:device2).imei)
    idle_events = IdleEvent.find :all
    assert_equal(3, idle_events.size, "should have allowed idle event on different device")
    
    insert_idle(2.2,2.3, now-200, devices(:device1).imei)
    idle_events = IdleEvent.find :all
    assert_equal(4, idle_events.size, "should allowed idle event in the past")
  end
  
  def test_runtime_insert
    RuntimeEvent.delete_all
    now = Time.now
    insert_runtime(1.2,2.3, now, devices(:device1).imei)
    runtime_events = RuntimeEvent.find :all
    assert_equal(1, runtime_events.size, "should have been one runtime event")
    
    insert_runtime(1.2, 2.3, now+60, devices(:device1).imei)
    runtime_events = RuntimeEvent.find :all
    assert_equal(1, runtime_events.size, "should have ignored duplicate runtime event")
    
    insert_runtime(1.2, 2.3, now, devices(:device1).imei)
    runtime_events = RuntimeEvent.find :all
    assert_equal(1, runtime_events.size, "should have ignored duplicate runtime event w/same timestamp")
    
    insert_runtime(2.2, 2.3, now+80, devices(:device2).imei)
    runtime_events = RuntimeEvent.find :all
    assert_equal(2, runtime_events.size, "should have allowed runtime event on different device")
    
    insert_runtime(2.2,2.3, now-200, devices(:device1).imei)
    runtime_events = RuntimeEvent.find :all
    assert_equal(3, runtime_events.size, "should allowed runtime event in the past")
  end
  
  def test_engine_off
    IdleEvent.delete_all
    now = Time.now
    insert_idle(1.2,2.3, now, devices(:device1).imei)
    idle_events = IdleEvent.find :all
    assert_equal(1, idle_events.size, "should have been one idle event")
    idle_event = IdleEvent.find(:first)
    assert_nil idle_event.duration
    
    insert_engine_off(1.2, 2.3, now+120, devices(:device1).imei)
    idle_event.reload
    assert_equal 5, idle_event.duration
  end
  
  def test_reading_insert
    Reading.delete_all
    now = Time.now
    #latitude, longitude, altitude, speed, heading, event_type, created_at
    ActiveRecord::Base.connection.execute("CALL insert_reading(1,2,3,4,5,#{devices(:device1).imei},'#{now.strftime("%Y-%m-%d %H:%M:%S")}', '' )")
    readings = Reading.find(:all)
    assert_equal 1, readings.size, "there should be only one reading"
    assert_equal 1, readings[0].latitude
    assert_equal 2, readings[0].longitude
    assert_equal 3, readings[0].altitude
    assert_equal 4, readings[0].speed
    assert_equal 5, readings[0].direction
    assert_equal now.to_s, readings[0].created_at.to_s
    assert_equal devices(:device1).id, readings[0].device_id
  end
  
  def test_reading_insert_with_io
    Reading.delete_all
    now = Time.now
    #latitude, longitude, altitude, speed, heading, event_type, created_at
    ActiveRecord::Base.connection.execute("CALL insert_reading_with_io(1,2,3,4,5,#{devices(:device1).imei},'#{now.strftime("%Y-%m-%d %H:%M:%S")}', '',1,0,1 )")
    readings = Reading.find(:all)
    assert_equal 1, readings.size, "there should be only one reading"
    assert_equal 1, readings[0].latitude
    assert_equal 2, readings[0].longitude
    assert_equal 3, readings[0].altitude
    assert_equal 4, readings[0].speed
    assert_equal 5, readings[0].direction
    assert_equal now.to_s, readings[0].created_at.to_s
    assert_equal devices(:device1).id, readings[0].device_id
    assert_equal true, readings[0].ignition
    assert_equal false, readings[0].gpio1
    assert_equal true, readings[0].gpio2
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
        assert_equal 23, stop_events(:two).duration
        assert_equal 28, stop_events(:three).duration
        assert_nil stop_events(:four).duration
  end
  
  def test_process_idles
        Reading.delete_all
        assert_equal 20, idle_events(:one).duration
        assert_nil idle_events(:two).duration
        assert_nil idle_events(:three).duration
        assert_nil idle_events(:four).duration
          
        Reading.new(:latitude => "4.5", :longitude => "5.6", :device_id => devices(:device1).id, :created_at => "2008-07-01 15:20:00", :speed => 10).save
        Reading.new(:latitude => "8.5", :longitude => "5.614", :device_id => devices(:device1).id, :created_at => "2008-07-01 16:25:00", :speed => 10).save
        ActiveRecord::Base.connection.execute("call process_idle_events()")
        
        idle_events(:two).reload
        idle_events(:three).reload
        idle_events(:four).reload
        
        assert_equal 20, idle_events(:one).duration
        assert_equal 23, idle_events(:two).duration
        assert_equal 28, idle_events(:three).duration
        assert_nil idle_events(:four).duration
  end
  
    def test_process_runtimes
        Reading.delete_all
        assert_equal 20, runtime_events(:one).duration
        assert_nil runtime_events(:two).duration
        assert_nil runtime_events(:three).duration
        assert_nil runtime_events(:four).duration
          
        Reading.new(:latitude => "4.5", :longitude => "5.6", :device_id => devices(:device1).id, :created_at => "2008-07-01 15:20:00", :speed => 10, :ignition => 0).save
        Reading.new(:latitude => "8.5", :longitude => "5.614", :device_id => devices(:device1).id, :created_at => "2008-07-01 16:25:00", :speed => 10, :ignition => 0).save
        ActiveRecord::Base.connection.execute("call process_runtime_events()")
        
        runtime_events(:two).reload
        runtime_events(:three).reload
        runtime_events(:four).reload
        
        assert_equal 20, runtime_events(:one).duration
        assert_equal 20, runtime_events(:two).duration
        assert_equal 25, runtime_events(:three).duration
        assert_nil runtime_events(:four).duration
  end
  
  def insert_stop(lat, lng, created, imei)
    ActiveRecord::Base.connection.execute("CALL insert_stop_event(#{lat},#{lng},'#{imei}','#{created.strftime("%Y-%m-%d %H:%M:%S")}', 42)")
  end
  
  def insert_idle(lat, lng, created, imei)
    ActiveRecord::Base.connection.execute("CALL insert_idle_event(#{lat},#{lng},'#{imei}','#{created.strftime("%Y-%m-%d %H:%M:%S")}', 42)")
  end
  
  def insert_engine_off(lat, lng, created, imei)
    ActiveRecord::Base.connection.execute("CALL insert_engine_off_event(#{lat},#{lng},'#{imei}','#{created.strftime("%Y-%m-%d %H:%M:%S")}', 42)")
  end
  
  def insert_runtime(lat, lng, created, imei)
    ActiveRecord::Base.connection.execute("CALL insert_runtime_event(#{lat},#{lng},'#{imei}','#{created.strftime("%Y-%m-%d %H:%M:%S")}', 42)")
  end
  
  
  end
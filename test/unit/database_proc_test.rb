require File.dirname(__FILE__) + '/../test_helper'

class DatabaseProcTest < Test::Unit::TestCase
  
  fixtures :devices
  
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
    StopEvent.delete_all
  end
  
  def test_stop_insert
    now = Time.now
    insert_stop(1.2,2.3, now, devices(:device1).imei)
    stops = StopEvent.find(:all)
    assert_equal(1, stops.size, "should have been one stop")
    
    insert_stop(1.2, 2.3, now+60, devices(:device1).imei)
    stops = StopEvent.find(:all)
    assert_equal(1, stops.size, "should have ignored duplicate stop")
    
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
  
  def insert_stop(lat, lng, created, imei)
    ActiveRecord::Base.connection.execute("CALL insert_stop_event(#{lat},#{lng},'#{imei}','#{created.strftime("%Y-%m-%d %H:%M:%S")}')")
  end
  
  end
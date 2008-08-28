require File.dirname(__FILE__) + '/../test_helper'

class Totalm2mTriggerTest < Test::Unit::TestCase
  
  fixtures :readings
  

  def setup
    setup_totalm2m_db()
    ActiveRecord::Base.establish_connection()
    setup_db_procs()
    Reading.delete_all
    Device.delete_all
  end
  
  def test_insert_device
    insert_device()
    devices = Device.find(:all)
    assert_equal 1, devices.size
    device = devices[0]
    assert_equal '010657000847181', device.imei
    assert_equal 0, device.account_id
    assert_equal 0, device.provision_status_id
    assert_nil device.name
    assert_equal 'Thu May 01 15:51:28 -0500 2008', device.last_online_time.to_s
    
  end
  
  def test_insert_event2
    insert_device
    test_reading_insert_old(2, 'normal_et2')
  end
  
  def test_insert_event3
    insert_device
    test_reading_insert(3, 'normal_et2')
  end
  
  def test_insert_event42
    insert_device
    test_reading_insert(42, 'startstop_et41')
    stops = Device.find(:first, :conditions => "imei='010657000847181'").stop_events
    assert_equal 1, stops.size
    assert_equal 32.9393, stops[0].latitude
    assert_equal -96.823, stops[0].longitude
    puts stops[0].reading_id
    assert_equal 'Thu Oct 11 12:57:28 -0500 2007', stops[0].created_at.to_s
  end
  
  def test_insert_event41
    insert_device
    test_reading_insert_old(41, 'startstop_et41')
  end
  
  def test_insert_event101
    insert_device
    test_reading_insert_with_io(101, 'normal')
  end
  
  def test_insert_event101_badgps
      insert_device
      test_reading_insert_with_io_badgps(101, 'normal')
  end
  
  def test_insert_event143_badgps
      insert_device
      test_reading_insert_with_io_badgps(143, 'idle')
  end
  
  def test_insert_event144_badgps
      insert_device
      test_reading_insert_with_io_badgps(144, 'engine off')
  end
  
  def test_insert_event145_badgps
      insert_device
      test_reading_insert_with_io_badgps(145, 'engine on')
  end
  
  def test_insert_event101
    insert_device
    test_reading_insert_with_io(101, 'normal')
  end
  
  def test_insert_event143
    insert_device
    test_reading_insert_with_io(143, 'idle')
  end
  
  def test_insert_event144
    insert_device
    test_reading_insert_with_io(144, 'engine off')
  end
  
  def test_insert_event145
    insert_device
    test_reading_insert_with_io(145, 'engine on')
  end
  
  def test_enter_geofences
    insert_device
    for i in 1..4
      test_reading_insert(20+i, 'entergeofen_et1'+i.to_s)
      Reading.delete_all
    end
  end
  
  def test_enter_geofences_old
    insert_device
    for i in 1..4
      test_reading_insert_old(10+i, 'entergeofen_et1'+i.to_s)
      Reading.delete_all
    end
  end
  
  def test_exit_geofences
    insert_device
    for i in 1..4
      test_reading_insert(60+i, 'exitgeofen_et5'+i.to_s)
      Reading.delete_all
    end
  end
  
  def test_exit_geofences_old
    insert_device
    for i in 1..4
      test_reading_insert_old(50+i, 'exitgeofen_et5'+i.to_s)
      Reading.delete_all
    end
  end
  
 
 
 def setup_totalm2m_db
   file = File.new("totalm2m.sql")
    sql = file.read
    statements = sql.split(';')
    
    statements.each  {|stmt| 
           ActiveRecord::Base.connection.execute(stmt)
    }
    setup_totalm2m_triggers()
 end
 
 def setup_totalm2m_triggers()
   file = File.new("totalm2m_triggers.sql")
    file.readline
    sql = file.read
    sql = sql.gsub('ublip_prod', 'ublip_v2_test')
    statements = sql.split(';;')
    
    statements.each  {|stmt| 
          ActiveRecord::Base.connection.execute(stmt)
    }
 end
 
 def test_reading_insert(table_number, event_type)
    ActiveRecord::Base.connection.execute("INSERT INTO ublip_totalm2m.EVENT_#{table_number} VALUES ('d739a720-0e43-4cfe-a2f2-065e87493766', '9354e7c9-74b8-4ba8-bbd5-6d1ec5d1d58c', '2007-10-11 18:02:02', '010657000847181', '010657000847181', 32.9393, -96.823, 100, 200, '2007-10-11 00:00:00', '1970-01-01 17:57:28', 211 ) ")
    readings = Reading.find(:all)
    assert_equal 1, readings.size
    reading = readings[0]
    assert_equal 32.9393, reading.latitude
    assert_equal -96.823, reading.longitude
    assert_equal 211, reading.altitude
    assert_equal 200, reading.direction
    assert_equal 12, reading.speed
    assert_equal 'Thu Oct 11 12:57:28 -0500 2007', reading.created_at.to_s
    assert_equal event_type, reading.event_type
 end
 
 def test_reading_insert_with_io(table_number, event_type)
    ActiveRecord::Base.connection.execute("INSERT INTO ublip_totalm2m.EVENT_#{table_number} VALUES ('d739a720-0e43-4cfe-a2f2-065e87493766', '9354e7c9-74b8-4ba8-bbd5-6d1ec5d1d58c', '2007-10-11 18:02:02', '010657000847181', '010657000847181', 'Y', 'N', 'Y', 'N', 'Y', 'N', 'Y', 'N' ,11 ,12, 32.9393, -96.823, 100, 200, '2007-10-11 00:00:00', '1970-01-01 17:57:28', 211 ) ")
    readings = Reading.find(:all)
    assert_equal 1, readings.size
    reading = readings[0]
    assert_equal 32.9393, reading.latitude
    assert_equal -96.823, reading.longitude
    assert_equal 211, reading.altitude
    assert_equal 200, reading.direction
    assert_equal 12, reading.speed
    assert_equal true, reading.gpio1;
    assert_equal false, reading.gpio2;
    assert_equal false, reading.ignition;
    assert_equal 'Thu Oct 11 12:57:28 -0500 2007', reading.created_at.to_s
    assert_equal event_type, reading.event_type
 end
 
 def test_reading_insert_with_io_badgps(table_number, event_type)
    ActiveRecord::Base.connection.execute("INSERT INTO ublip_totalm2m.EVENT_#{table_number} VALUES ('d739a720-0e43-4cfe-a2f2-065e87493766', '9354e7c9-74b8-4ba8-bbd5-6d1ec5d1d58c', '2007-10-11 18:02:02', '010657000847181', '010657000847181', 'Y', 'N', 'Y', 'N', 'Y', 'N', 'Y', 'N' ,11 ,12, 32.9393, -96.823, 100, 200, '2063-01-01 00:00:00', '1970-01-01 17:57:28', 211 ) ")
    readings = Reading.find(:all)
    assert_equal 1, readings.size
    reading = readings[0]
    assert_equal 32.9393, reading.latitude
    assert_equal -96.823, reading.longitude
    assert_equal 211, reading.altitude
    assert_equal 200, reading.direction
    assert_equal 12, reading.speed
    assert_equal true, reading.gpio1;
    assert_equal false, reading.gpio2;
    assert_equal false, reading.ignition;
    assert_equal 'Thu Oct 11 18:02:02 -0500 2007', reading.created_at.to_s
    assert_equal event_type, reading.event_type
 end
 
 def test_reading_insert_old(table_number, event_type)
    ActiveRecord::Base.connection.execute("INSERT INTO ublip_totalm2m.EVENT_#{table_number} VALUES ('d739a720-0e43-4cfe-a2f2-065e87493766', '9354e7c9-74b8-4ba8-bbd5-6d1ec5d1d58c', '2007-10-11 18:02:02', '010657000847181', '010657000847181', 32.9393, -96.823, 100, 200, 211 ) ")
    readings = Reading.find(:all)
    assert_equal 1, readings.size
    reading = readings[0]
    assert_equal 32.9393, reading.latitude
    assert_equal -96.823, reading.longitude
    assert_equal 211, reading.altitude
    assert_equal 200, reading.direction
    assert_equal 12, reading.speed
    assert_equal 'Thu Oct 11 13:02:02 -0500 2007', reading.created_at.to_s
    assert_equal event_type, reading.event_type
 end
 
 def insert_device
   ActiveRecord::Base.connection.execute("INSERT INTO ublip_totalm2m.DEVICE VALUES ('010657000847181', NULL, NULL, NULL, '010657000847181', '10.6.0.1', 1720, '0.0.0.0', 1720, '2008-03-18 16:13:27', '2008-05-01 20:51:28', '2008-05-01 20:51:28', '2008-05-01 20:51:28', '2008-03-18 16:13:32', 0 )")
 end
 
 def setup_db_procs
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


end


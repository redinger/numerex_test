DELIMITER ;;
USE ublip_prod;;

DROP FUNCTION IF EXISTS distance;;
CREATE FUNCTION distance (	
	lat1 FLOAT,
	lng1 FLOAT,
	lat2 FLOAT,
	lng2 FLOAT
) RETURNS FLOAT
DETERMINISTIC
COMMENT 'Calculate distance between two points in miles'
BEGIN
	RETURN (((acos(sin((lat1*pi()/180)) * sin((lat2*pi()/180)) + cos((lat1*pi()/180)) * cos((lat2*pi()/180)) 
   * cos(((lng1 - lng2)*pi()/180))))*180/pi())*60*1.1515);
END;;

/*comment to make netbeans sql editor happy*/


DROP PROCEDURE IF EXISTS insert_stop_event;;
CREATE PROCEDURE insert_stop_event(
	_latitude FLOAT,
	_longitude FLOAT,
	_modem VARCHAR(22),
	_created DATETIME,
	_reading_id INT(11)
)
BEGIN
	DECLARE deviceID INT(11);
	DECLARE latestStopID INT(11);
	
	SELECT id INTO deviceID FROM devices WHERE imei=_modem;
	
	IF deviceID IS NOT NULL THEN
		SELECT id INTO latestStopID FROM stop_events WHERE device_id=deviceID AND created_at <= _created ORDER BY created_at desc limit 1;
		IF (SELECT id FROM stop_events WHERE id=latestStopID AND duration IS NULL and distance(_latitude, _longitude, latitude, longitude) < 0.1) IS NULL THEN
			INSERT INTO stop_events (latitude, longitude, created_at, device_id, reading_id)
		   		VALUES (_latitude, _longitude, _created, deviceID, _reading_id);
		END IF;
	END IF;
END;;

DROP PROCEDURE IF EXISTS insert_idle_event;;
CREATE PROCEDURE insert_idle_event(
	_latitude FLOAT,
	_longitude FLOAT,
	_modem VARCHAR(22),
	_created DATETIME,
	_reading_id INT(11)
)
BEGIN
	DECLARE deviceID INT(11);
	DECLARE latestIdleID INT(11);
	
	SELECT id INTO deviceID FROM devices WHERE imei=_modem;
	
	IF deviceID IS NOT NULL THEN
		SELECT id INTO latestIdleID FROM idle_events WHERE device_id=deviceID AND created_at <= _created ORDER BY created_at desc limit 1;
		IF (SELECT id FROM idle_events WHERE id=latestIdleID AND duration IS NULL and distance(_latitude, _longitude, latitude, longitude) < 0.1) IS NULL THEN
			INSERT INTO idle_events (latitude, longitude, created_at, device_id, reading_id)
		   		VALUES (_latitude, _longitude, _created, deviceID, _reading_id);
		END IF;
	END IF;
END;;

DROP PROCEDURE IF EXISTS insert_runtime_event;;
CREATE PROCEDURE insert_runtime_event(
	_latitude FLOAT,
	_longitude FLOAT,
	_modem VARCHAR(22),
	_created DATETIME,
	_reading_id INT(11)
)
BEGIN
	DECLARE deviceID INT(11);
	DECLARE latestRuntimeID INT(11);
	
	SELECT id INTO deviceID FROM devices WHERE imei=_modem;
	
	IF deviceID IS NOT NULL THEN
		SELECT id INTO latestRuntimeID FROM runtime_events WHERE device_id=deviceID AND created_at <= _created ORDER BY created_at desc limit 1;
		IF (SELECT id FROM runtime_events WHERE id=latestRuntimeID AND duration IS NULL) IS NULL THEN
			INSERT INTO runtime_events (latitude, longitude, created_at, device_id, reading_id)
		   		VALUES (_latitude, _longitude, _created, deviceID, _reading_id);
		END IF;
	END IF;
END;;

DROP PROCEDURE IF EXISTS insert_engine_off_event;;
CREATE PROCEDURE insert_engine_off_event(
	_latitude FLOAT,
	_longitude FLOAT,
	_modem VARCHAR(22),
	_created DATETIME,
	_reading_id INT(11)
)
BEGIN
	
END;;


DROP PROCEDURE IF EXISTS insert_reading;;
CREATE PROCEDURE insert_reading(
	_latitude FLOAT,
	_longitude FLOAT,
	_altitude  FLOAT,
	_speed FLOAT,
	_heading float,
	_modem VARCHAR(22),
	_created DATETIME,
	_event_type VARCHAR(25)
)
BEGIN
	DECLARE deviceID INT(11);
	
	SELECT id INTO deviceID FROM devices WHERE imei=_modem;
	INSERT INTO readings (device_id, latitude, longitude, altitude, speed, direction, event_type, created_at)
		VALUES (deviceID, _latitude, _longitude, _altitude, _speed, _heading, _event_type, _created);
END;;

DROP PROCEDURE IF EXISTS insert_reading_with_io;;
CREATE PROCEDURE insert_reading_with_io(
	_latitude FLOAT,
	_longitude FLOAT,
	_altitude  FLOAT,
	_speed FLOAT,
	_heading float,
	_modem VARCHAR(22),
	_created DATETIME,
	_event_type VARCHAR(25),
	_ignition TINYINT(1),
	_gpio1 TINYINT(1),
	_gpio2 TINYINT(1)
)
BEGIN
	SELECT id INTO @deviceID FROM devices WHERE imei=_modem;
	INSERT INTO readings (device_id, latitude, longitude, altitude, speed, direction, event_type, created_at, ignition, gpio1, gpio2)
		VALUES (@deviceID, _latitude, _longitude, _altitude, _speed, _heading, _event_type, _created, _ignition, _gpio1, _gpio2);
END;;

DROP PROCEDURE IF EXISTS process_stop_events;;
CREATE PROCEDURE process_stop_events()
BEGIN
	DECLARE num_events_to_check INT;
	CREATE TEMPORARY TABLE open_stop_events(stop_event_id INT(11), checked BOOLEAN);
	INSERT INTO open_stop_events SELECT id, FALSE FROM stop_events where duration IS NULL;
	SELECT COUNT(*) INTO num_events_to_check FROM open_stop_events WHERE checked=FALSE;
	WHILE num_events_to_check>0 DO BEGIN
		DECLARE eventID INT;
		DECLARE first_move_after_stop_id INT;
		DECLARE stopDuration INT;
		DECLARE deviceID INT;
		DECLARE stopTime DATETIME;
		
		SELECT stop_event_id INTO eventID FROM open_stop_events WHERE checked=FALSE limit 1;
		SELECT device_id, created_at into deviceID, stopTime FROM stop_events where id=eventID;
		UPDATE open_stop_events SET checked=TRUE WHERE stop_event_id=eventId;
		
		SELECT id INTO first_move_after_stop_id FROM readings  
		  WHERE device_id=deviceID AND speed>1 AND created_at>stopTime ORDER BY created_at ASC LIMIT 1;
		  
		IF first_move_after_stop_id IS NOT NULL THEN
			SELECT TIMESTAMPDIFF(MINUTE, stopTime, created_at) INTO stopDuration FROM readings where id=first_move_after_stop_id;
			UPDATE stop_events SET duration = stopDuration+3 where id=eventID;
		END IF;
		
		SELECT COUNT(*) INTO num_events_to_check FROM open_stop_events WHERE checked=FALSE;
	END;
	END WHILE;
END;;

DROP PROCEDURE IF EXISTS process_idle_events;;
CREATE PROCEDURE process_idle_events()
BEGIN
	DECLARE num_events_to_check INT;
	DROP TEMPORARY TABLE IF EXISTS open_idle_events;
	CREATE TEMPORARY TABLE open_idle_events(idle_event_id INT(11), checked BOOLEAN);
	INSERT INTO open_idle_events SELECT id, FALSE FROM idle_events where duration IS NULL;
	SELECT COUNT(*) INTO num_events_to_check FROM open_idle_events WHERE checked=FALSE;
	WHILE num_events_to_check>0 DO BEGIN
		DECLARE eventID INT;
		DECLARE first_move_or_off_after_idle_id INT;
		DECLARE idleDuration INT;
		DECLARE deviceID INT;
		DECLARE idleTime DATETIME;
		
		SELECT idle_event_id INTO eventID FROM open_idle_events WHERE checked=FALSE limit 1;
		SELECT device_id, created_at into deviceID, idleTime FROM idle_events where id=eventID;
		UPDATE open_idle_events SET checked=TRUE WHERE idle_event_id=eventId;
		
		SELECT id INTO first_move_or_off_after_idle_id FROM readings  
		  WHERE device_id=deviceID AND (speed>1 OR ignition=0) AND created_at>idleTime ORDER BY created_at ASC LIMIT 1;
		  
		IF first_move_or_off_after_idle_id IS NOT NULL THEN	 
			SELECT TIMESTAMPDIFF(MINUTE, idleTime, created_at) INTO idleDuration FROM readings where id=first_move_or_off_after_idle_id;
			UPDATE idle_events SET duration = idleDuration+3 where id=eventID;
		END IF;
		
		SELECT COUNT(*) INTO num_events_to_check FROM open_idle_events WHERE checked=FALSE;
	END;
	END WHILE;
END;;

DROP PROCEDURE IF EXISTS process_runtime_events;;
CREATE PROCEDURE process_runtime_events()
BEGIN
	DECLARE num_events_to_check INT;
	CREATE TEMPORARY TABLE open_runtime_events(runtime_event_id INT(11), checked BOOLEAN);
	INSERT INTO open_runtime_events SELECT id, FALSE FROM runtime_events where duration IS NULL;
	SELECT COUNT(*) INTO num_events_to_check FROM open_runtime_events WHERE checked=FALSE;
	WHILE num_events_to_check>0 DO BEGIN
		DECLARE eventID INT;
		DECLARE first_off_after_runtime_id INT;
		DECLARE runtimeDuration INT;
		DECLARE deviceID INT;
		DECLARE runtimeTime DATETIME;
		
		SELECT runtime_event_id INTO eventID FROM open_runtime_events WHERE checked=FALSE limit 1;
		SELECT device_id, created_at into deviceID, runtimeTime FROM runtime_events where id=eventID;
		UPDATE open_runtime_events SET checked=TRUE WHERE runtime_event_id=eventId;
		
		SELECT id INTO first_off_after_runtime_id FROM readings  
		  WHERE device_id=deviceID AND ignition=0 AND created_at>runtimeTime ORDER BY created_at ASC LIMIT 1;
		  
		IF first_off_after_runtime_id IS NOT NULL THEN	 
			SELECT TIMESTAMPDIFF(MINUTE, runtimeTime, created_at) INTO runtimeDuration FROM readings where id=first_off_after_runtime_id;
			UPDATE runtime_events SET duration = runtimeDuration where id=eventID;
		END IF;
		
		SELECT COUNT(*) INTO num_events_to_check FROM open_runtime_events WHERE checked=FALSE;
	END;
	END WHILE;
END;;

DROP PROCEDURE IF EXISTS create_stop_events;;
CREATE PROCEDURE create_stop_events()
BEGIN
        DROP TEMPORARY TABLE IF EXISTS new_stops;
        CREATE TEMPORARY TABLE new_stops(latitude float, longitude float, imei VARCHAR(22), created DATETIME, reading_id INT(11), processed BOOLEAN);
            INSERT INTO new_stops SELECT r.latitude, r.longitude, d.imei, r.created_at, r.id, FALSE FROM devices d, readings r
            WHERE d.gateway_name='xirgo' AND r.id=d.recent_reading_id AND r.speed=0 AND TIMESTAMPDIFF(MINUTE, r.created_at, now())>3;
        
        SELECT COUNT(*) INTO @i FROM new_stops WHERE processed=FALSE;
        WHILE @i > 0 DO BEGIN
            SELECT latitude, longitude, imei, created, reading_id INTO @lat, @lng, @imei, @created, @reading_id FROM new_stops WHERE processed=FALSE LIMIT 1;
            CALL insert_stop_event(@lat, @lng, @imei, @created, @reading_id);
            UPDATE new_stops SET processed=TRUE WHERE reading_id=@reading_id;
            SELECT COUNT(*) INTO @i FROM new_stops WHERE processed=FALSE;
        END;
        END WHILE;
END;;

DROP PROCEDURE IF EXISTS migrate_stop_data;;
CREATE PROCEDURE migrate_stop_data()
BEGIN
	DECLARE unprocessed_count INT;
	DROP TEMPORARY TABLE IF EXISTS stops;
	CREATE TEMPORARY TABLE stops(latitude FLOAT, longitude FLOAT, modem VARCHAR(22), created DATETIME, reading_id INT(11), processed BOOLEAN );
	INSERT INTO stops SELECT r.latitude, r.longitude, d.imei, r.created_at, r.id, false FROM readings r, devices d WHERE d.id=r.device_id AND r.speed=0 AND r.event_type like '%stop%';
	CREATE INDEX idx_created ON stops (created); 
    SELECT COUNT(*) INTO unprocessed_count FROM stops where processed=FALSE;
	WHILE unprocessed_count > 0 DO BEGIN
		DECLARE lat FLOAT;
		DECLARE lng FLOAT;
		DECLARE imei VARCHAR(22);
		DECLARE created_at DATETIME;
		DECLARE readingID INT(11);
		
		SELECT latitude,longitude,modem,created,reading_id INTO lat,lng,imei,created_at,readingID FROM stops WHERE processed=FALSE order by created asc limit 1;
		CALL insert_stop_event(lat, lng, imei, created_at, readingID);
		UPDATE stops SET processed=TRUE where reading_id=readingID;
		SELECT COUNT(*) INTO unprocessed_count FROM stops where processed=FALSE;
	END;
	END WHILE;
END;;

DROP TRIGGER IF EXISTS trig_readings_after_insert;;
CREATE TRIGGER trig_readings_after_insert AFTER INSERT ON readings FOR EACH ROW BEGIN
    DECLARE last_reading_time DATETIME;
    CALL check_for_trip_change(NEW.device_id, NEW.id, NEW.created_at, NEW.ignition);
    SELECT r.created_at INTO last_reading_time FROM devices d,readings r WHERE d.id=NEW.device_id AND r.id=d.recent_reading_id;
    IF NEW.created_at >= last_reading_time OR last_reading_time IS NULL THEN
        UPDATE devices SET recent_reading_id=NEW.id WHERE id=NEW.device_id;
    END IF;
END;;

DROP PROCEDURE IF EXISTS insert_trip_event;;
CREATE PROCEDURE insert_trip_event( _reading_start_id INT(11) )
BEGIN
    DECLARE identical_trip_count INT(11);
    SELECT count(*) INTO identical_trip_count FROM trip_events te, readings r
        where r.id=_reading_start_id AND te.created_at=r.created_at AND te.device_id=r.device_id;
    IF identical_trip_count=0 THEN
        INSERT INTO trip_events (device_id, reading_start_id, created_at) SELECT device_id, id, created_at FROM readings where id=_reading_start_id;
    END IF;
END;;

DROP PROCEDURE IF EXISTS check_for_trip_change;;
CREATE PROCEDURE check_for_trip_change(
    _device_id INT(11),
    _reading_id INT(11),
    _timestamp DATETIME,
    _ignition BOOLEAN
)
BEGIN
    DECLARE previous_ignition boolean;
    SELECT ignition INTO previous_ignition FROM readings WHERE device_id=_device_id AND created_at < _timestamp AND ignition IS NOT NULL ORDER BY created_at DESC LIMIT 1;
    IF _ignition=TRUE AND (previous_ignition=FALSE OR previous_ignition IS NULL) THEN
        CALL insert_trip_event(_reading_id);
    END IF;
    IF _ignition=FALSE AND previous_ignition=TRUE THEN
        SELECT duration,id INTO @duration,@trip_id FROM trip_events WHERE device_id=_device_id AND created_at<_timestamp ORDER BY created_at desc limit 1;
        IF @duration IS NULL THEN
            UPDATE trip_events SET reading_stop_id=_reading_id, duration=TIMESTAMPDIFF(MINUTE,created_at,_timestamp) WHERE id=@trip_id;
        END IF;
    END IF;
END;;
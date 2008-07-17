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

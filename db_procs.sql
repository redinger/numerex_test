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
			UPDATE stop_events SET duration = stopDuration where id=eventID;
		END IF;
		
		SELECT COUNT(*) INTO num_events_to_check FROM open_stop_events WHERE checked=FALSE;
	END;
	END WHILE;
END;;

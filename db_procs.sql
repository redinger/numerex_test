DELIMITER ;;
USE ublip_prod;;

DROP PROCEDURE IF EXISTS insert_stop_event;;
CREATE PROCEDURE insert_stop_event(
	_latitude FLOAT,
	_longitude FLOAT,
	_modem VARCHAR(22),
	_created DATETIME
)
BEGIN
	DECLARE deviceID INT(11);
	DECLARE latestStopID INT(11);
	
	SELECT id INTO deviceID FROM devices WHERE imei=_modem;
	
	IF deviceID IS NOT NULL THEN
		SELECT id INTO latestStopID FROM stop_events WHERE device_id=deviceID AND created_at < _created ORDER BY created_at desc limit 1;
		IF (SELECT id FROM stop_events WHERE id=latestStopID AND duration IS NULL and distance(_latitude, _longitude, latitude, longitude) < 0.1) IS NULL THEN
			INSERT INTO stop_events (latitude, longitude, created_at, device_id)
		   		VALUES (_latitude, _longitude, _created, deviceID);
		END IF;
	END IF;
END;;

DROP PROCEDURE IF EXISTS process_stop_events;;
CREATE PROCEDURE process_stop_events()
BEGIN

END;;

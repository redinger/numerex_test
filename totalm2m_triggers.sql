DELIMITER ;;
use ublip_totalm2m ;;

drop TRIGGER IF EXISTS`trig_device_insert_toublip` ;;
create TRIGGER `trig_device_insert_toublip` after insert on `DEVICE` for each row
BEGIN
 DECLARE tempid int(11);
 DECLARE onlinetime DATETIME;
 SET onlinetime = CONVERT_TZ(NEW.LAST_RECV,'UTC','US/Pacific');
 SELECT id INTO tempid FROM `ublip_prod`.`devices` WHERE imei = NEW.ID LIMIT 1;
 IF tempid IS NULL AND New.ID IS NOT NULL THEN
     INSERT INTO `ublip_prod`.`devices` (imei,created_at,last_online_time)
     VALUES (NEW.ID,NEW.CREATED,onlinetime);
 END IF;
END;;

drop TRIGGER IF EXISTS `trig_device_update_toublip` ;;
create TRIGGER `trig_device_update_toublip` after update on `DEVICE` for each row
BEGIN
 DECLARE tempid int(11);
 DECLARE onlinetime DATETIME;
 SET onlinetime = CONVERT_TZ(NEW.LAST_RECV,'UTC','US/Pacific');
 SELECT id INTO tempid FROM `ublip_prod`.`devices` WHERE imei = NEW.ID LIMIT 1;
 IF tempid IS NULL AND New.ID IS NOT NULL THEN
     INSERT INTO `ublip_prod`.`devices` (imei,created_at,last_online_time)
     VALUES (NEW.ID,NEW.CREATED,onlinetime);
 ELSE
   UPDATE `ublip_prod`.`devices` set imei=NEW.ID,created_at=NEW.CREATED,last_online_time=onlinetime
    where id = tempid;
 END IF;
END;;

drop TRIGGER IF EXISTS `trig_event_11_insert_toublip` ;;
CREATE TRIGGER `trig_event_11_insert_toublip` AFTER INSERT ON `EVENT_11` FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  NEW.created, 'entergeofen_et11');
END;;

drop TRIGGER IF EXISTS `trig_event_12_insert_toublip` ;;
CREATE TRIGGER `trig_event_12_insert_toublip` AFTER INSERT ON `EVENT_12` FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  NEW.created, 'entergeofen_et12');
END;;

drop TRIGGER IF EXISTS `trig_event_13_insert_toublip` ;;
CREATE TRIGGER `trig_event_13_insert_toublip` AFTER INSERT ON `EVENT_13` FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  NEW.created, 'entergeofen_et13');
END;;

drop TRIGGER IF EXISTS `trig_event_14_insert_toublip` ;;
CREATE TRIGGER `trig_event_14_insert_toublip` AFTER INSERT ON `EVENT_14` FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  NEW.created, 'entergeofen_et14');
END;;

drop TRIGGER IF EXISTS `trig_event_2_insert_toublip` ;;
CREATE TRIGGER `trig_event_2_insert_toublip` AFTER INSERT ON `EVENT_2` FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  NEW.created, 'normal_et2');
END;;

drop TRIGGER IF EXISTS `trig_event_40_insert_toublip` ;;
CREATE TRIGGER `trig_event_40_insert_toublip` AFTER INSERT ON `EVENT_40` FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  NEW.created, 'speeding_et40');
END;;

drop TRIGGER IF EXISTS`trig_event_41_insert_toublip` ;;
CREATE TRIGGER `trig_event_41_insert_toublip` AFTER INSERT ON `EVENT_41` FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  NEW.created, 'startstop_et41');
END;;

drop TRIGGER IF EXISTS `trig_event_51_insert_toublip` ;;
CREATE TRIGGER `trig_event_51_insert_toublip` AFTER INSERT ON `EVENT_51` FOR EACH ROW BEGIN
CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  NEW.created, 'exitgeofen_et51');
END;;

drop TRIGGER IF EXISTS `trig_event_52_insert_toublip` ;;
CREATE TRIGGER `trig_event_52_insert_toublip` AFTER INSERT ON `EVENT_52` FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  NEW.created, 'exitgeofen_et52');
END;;

drop TRIGGER IF EXISTS `trig_event_53_insert_toublip` ;;
CREATE TRIGGER `trig_event_53_insert_toublip` AFTER INSERT ON `EVENT_53` FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  NEW.created, 'exitgeofen_et53');
END;;

drop TRIGGER IF EXISTS `trig_event_54_insert_toublip` ;;
CREATE TRIGGER `trig_event_54_insert_toublip` AFTER INSERT ON `EVENT_54` FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  NEW.created, 'exitgeofen_et54');
END;;


drop trigger IF EXISTS trig_event_3_insert_toublip;;
CREATE TRIGGER trig_event_3_insert_toublip AFTER INSERT ON EVENT_3 FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  concat_ws(' ', DATE(NEW.UTC_GPS_DATE), TIME(NEW.UTC_GPS_TIME)), 'normal_et2');
END;;

drop trigger IF EXISTS trig_event_21_insert_toublip;;
CREATE TRIGGER trig_event_21_insert_toublip AFTER INSERT ON EVENT_21 FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  concat_ws(' ', DATE(NEW.UTC_GPS_DATE), TIME(NEW.UTC_GPS_TIME)), 'entergeofen_et11');
END;;

drop trigger IF EXISTS trig_event_22_insert_toublip;;
CREATE TRIGGER trig_event_22_insert_toublip AFTER INSERT ON EVENT_22 FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  concat_ws(' ', DATE(NEW.UTC_GPS_DATE), TIME(NEW.UTC_GPS_TIME)), 'entergeofen_et12');
END;;

drop trigger IF EXISTS trig_event_23_insert_toublip;;
CREATE TRIGGER trig_event_23_insert_toublip AFTER INSERT ON EVENT_23 FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  concat_ws(' ', DATE(NEW.UTC_GPS_DATE), TIME(NEW.UTC_GPS_TIME)), 'entergeofen_et13');
END;;

drop trigger IF EXISTS trig_event_24_insert_toublip;;
CREATE TRIGGER trig_event_24_insert_toublip AFTER INSERT ON EVENT_24 FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  concat_ws(' ', DATE(NEW.UTC_GPS_DATE), TIME(NEW.UTC_GPS_TIME)), 'entergeofen_et14');
END;;

drop trigger IF EXISTS trig_event_42_insert_toublip;;
CREATE TRIGGER trig_event_42_insert_toublip AFTER INSERT ON EVENT_42 FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  concat_ws(' ', DATE(NEW.UTC_GPS_DATE), TIME(NEW.UTC_GPS_TIME)), 'startstop_et41');
END;;

drop trigger IF EXISTS trig_event_61_insert_toublip;;
CREATE TRIGGER trig_event_61_insert_toublip AFTER INSERT ON EVENT_61 FOR EACH ROW BEGIN
CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  concat_ws(' ', DATE(NEW.UTC_GPS_DATE), TIME(NEW.UTC_GPS_TIME)), 'exitgeofen_et51');
END;;

drop trigger IF EXISTS trig_event_62_insert_toublip;;
CREATE TRIGGER trig_event_62_insert_toublip AFTER INSERT ON EVENT_62 FOR EACH ROW BEGIN
 CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  concat_ws(' ', DATE(NEW.UTC_GPS_DATE), TIME(NEW.UTC_GPS_TIME)), 'exitgeofen_et52');
END;;

drop trigger IF EXISTS trig_event_63_insert_toublip;;
CREATE TRIGGER trig_event_63_insert_toublip AFTER INSERT ON EVENT_63 FOR EACH ROW BEGIN
	CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  concat_ws(' ', DATE(NEW.UTC_GPS_DATE), TIME(NEW.UTC_GPS_TIME)), 'exitgeofen_et53');
END;;

drop trigger IF EXISTS trig_event_64_insert_toublip;;
CREATE TRIGGER trig_event_64_insert_toublip AFTER INSERT ON EVENT_64 FOR EACH ROW BEGIN
	CALL insert_readings(NEW.latitude, NEW.longitude, NEW.altitude, NEW.speed, NEW.heading, NEW.modem, 
	  concat_ws(' ', DATE(NEW.UTC_GPS_DATE), TIME(NEW.UTC_GPS_TIME)), 'exitgeofen_et54');
END;;

DROP PROCEDURE IF EXISTS insert_readings;;
CREATE PROCEDURE insert_readings(
	_latitude FLOAT,
	_longitude FLOAT,
	_altitude INT(11),
	_speed INT(11),
	_heading INT(11),
	_modem VARCHAR(22),
	_created DATETIME,
	_event_type VARCHAR(25)
)
BEGIN
	DECLARE tempid int(11);
 	DECLARE testlat float;
 	DECLARE timestamp DATETIME;
 	SET timestamp = CONVERT_TZ(_created,'UTC', get_system_timezone() );
 	SELECT id INTO tempid FROM ublip_prod.devices WHERE imei = _modem LIMIT 1;
 	SET testlat = _latitude;
 	IF testlat IS NOT NULL AND testlat != 0 THEN
   		INSERT INTO ublip_prod.readings (latitude,longitude,altitude,speed,direction,device_id,created_at,event_type)
    		VALUES
      		(_latitude, _longitude, _altitude, KNOTS_X_TEN_TO_MPH(_speed), _heading, tempid, timestamp, _event_type);
    UPDATE ublip_prod.devices SET recent_reading_id = LAST_INSERT_ID() where id=tempid;
 END IF;
END;;

DROP FUNCTION IF EXISTS knots_x_ten_to_mph;;
CREATE FUNCTION knots_x_ten_to_mph (tenknots DOUBLE)
RETURNS FLOAT
DETERMINISTIC
BEGIN
RETURN tenknots * .115077945;
END;;

DROP FUNCTION IF EXISTS get_system_timezone;;
CREATE FUNCTION get_system_timezone ()
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
CASE @@system_time_zone
	WHEN 'GMT' THEN RETURN 'UTC';
	WHEN 'CDT' THEN RETURN 'US/Central';
	WHEN 'PDT' THEN RETURN 'US/Pacific';
END CASE;
END;;
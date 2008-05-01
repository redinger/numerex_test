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

DROP TRIGGER IF EXISTS trig_readings_insert;;
CREATE TRIGGER trig_readings_insert BEFORE INSERT ON readings FOR EACH ROW BEGIN
	
	DECLARE new_violation_count int;
	DECLARE first_fence_num int;
	DECLARE geofence_exit_count int;
	DECLARE proceed boolean;
		
		SET proceed = true;
	    DROP TEMPORARY TABLE IF EXISTS temp_violated_fences;
		CREATE TEMPORARY TABLE temp_violated_fences (fence_id int, fence_num int);
		
		INSERT INTO temp_violated_fences SELECT id, fence_num FROM geofences 
		   WHERE distance(NEW.latitude, NEW.longitude, latitude, longitude) < radius
		     AND id NOT IN (SELECT geofence_id from geofence_violations where device_id=NEW.device_id) 
		     AND device_id=NEW.device_id;
		
		#insert new violations into geofence_violations table
		INSERT INTO geofence_violations (geofence_id, device_id) SELECT fence_id, NEW.device_id FROM temp_violated_fences limit 1;
		
		SELECT count(*) from temp_violated_fences into new_violation_count;
		  
		IF new_violation_count>0 THEN
		  SELECT fence_num into first_fence_num from temp_violated_fences order by fence_num limit 1;
		  SET NEW.event_type = CONCAT('enter_geofen', first_fence_num);
		  SET proceed = false; 
		END IF; 
		
		IF proceed=true THEN
			DROP TEMPORARY TABLE IF EXISTS temp_exited_fences;
			CREATE TEMPORARY TABLE temp_exited_fences (fence_id int, fence_num int);
		
			INSERT INTO temp_exited_fences SELECT g.id, g.fence_num FROM geofence_violations v, geofences g 
		  		WHERE g.id=v.geofence_id AND distance(NEW.latitude, NEW.longitude, g.latitude, g.longitude) > g.radius
		    	AND g.device_id=NEW.device_id;
		
			SELECT count(*) FROM temp_exited_fences INTO geofence_exit_count;
		
			IF geofence_exit_count > 0 THEN
		  		SELECT fence_num INTO first_fence_num FROM temp_exited_fences ORDER BY fence_num LIMIT 1;
		  		SET NEW.event_type = CONCAT('exit_geofen', first_fence_num);
		  		DELETE FROM geofence_violations WHERE device_id=NEW.device_id 
		    		AND geofence_id=(SELECT fence_id from temp_exited_fences WHERE fence_num=first_fence_num);
			END IF;
		END IF;
END;;
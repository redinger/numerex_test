# Controller that receives readings from HTTP devices
# Verifies that the device currently exists and associates data
# with appropriate device and account
class WsController < ApplicationController

  # Supports url params imei, lat, lng, spd, dir alt
  def index
    # Check that the device exists
    device = Device.find_by_imei(params[:imei])
    
    if device
      # TODO data check/validation
      reading = Reading.new
      reading.latitude = params[:lat]
      reading.longitude = params[:lng]
      reading.altitude = params[:alt]
      reading.speed = params[:spd]
      reading.direction = params[:dir]
      reading.note = params[:note]
      reading.device_id = device.id
      reading.event_type = "DEFAULT"
      
      # Save the reading
      if reading.save
        # Save the reading id with the device
        device.recent_reading_id = reading.id
        device.save
        render :text => "Success"
      else
        render :text => "Error saving data"
      end
    # Error finding device
    else
       render :text => "We're sorry, this device does not exist"
    end
  end
  
  # Simple Sanav integration
  # Request from logs Parameters: {"action"=>"sanav", "controller"=>"ws", "imei"=>"352023003616634", "rmc"=>"$GPRMC,055104.000,A,2906.5967,N,08058.9034,W,0.00,0.00,120408,,*10,AUTO"}
  def sanav
    device = Device.find_by_imei(params[:imei])
    
    if device
      rmc = params[:rmc]
      
      # Convert lat lng from degrees minutes to decimal degrees
      rmc = rmc.split(",")
      lat = rmc[3]
      lng = rmc[5]
      spd = rmc[7]
      
      lat_deg = lat.slice(0,2).to_f
      lng_deg = lng.slice(0,3).to_f

      lat_min = lat.slice(2, lat.length-2)
      lng_min = lng.slice(3, lng.length-2)

      lat_min = lat_min.to_f/60
      lng_min = lng_min.to_f/60

      lat = lat_deg.to_f+lat_min.to_f
      lng = lng_deg.to_f+lng_min.to_f
      
      reading = Reading.new
      reading.latitude = lat
      reading.longitude = "-" + lng.to_s
      reading.device_id = device.id
      reading.speed = spd
      reading.event_type = "DEFAULT"
      
      # Save the reading
      if reading.save
        # Save the reading id with the device
        device.recent_reading_id = reading.id
        device.save
        render_text "Success"
      else
        render_text "Error saving data"
      end
    # Error finding device
      
    else
      render_text "We're sorry, this device does not exist"
    end
  end
end

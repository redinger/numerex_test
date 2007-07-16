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

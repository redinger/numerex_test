class GatewayController < ApplicationController
  # Handles name/value pairs sent from device and routes accordingly
  def index
    location = Location.new
    location.latitude = params[:lat]
    location.longitude = params[:lng]
    location.device_id = params[:device_id]
    location.altitude = params[:alt]
    location.speed = params[:spd]
    location.direction = params[:dir]
    location.save
    
    device = Device.find(params[:device_id])
    device.latitude = params[:lat]
    device.longitude = params[:lng]
    device.altitude = params[:alt]
    device.speed = params[:spd]
    device.direction = params[:dir]
    
    device.save
    
    render_text 'success'
  end
  
  # Displays map and devices and allows for data insertion
  def insert_location
    @devices = Device.find(:all)
  end
  
  
end

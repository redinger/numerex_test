class GatewayController < ApplicationController
  # Handles name/value pairs sent from device and routes accordingly
  def index
    location = Location.new
    location.latitude = params[:lat]
    location.longitude = params[:lng]
    location.device_id = params[:device_id]
    location.save
    
    device = Device.find(params[:device_id])
    device.latitude = params[:lat]
    device.longitude = params[:lng]
    device.save
    
    render_text 'success'
  end
  
  # Displays map and devices and allows for data insertion
  def insert_location
    @devices = Device.find(:all)
  end
  
  
end

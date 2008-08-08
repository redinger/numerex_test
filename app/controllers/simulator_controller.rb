class SimulatorController < ApplicationController
  before_filter :authorize

  def index
    @devices = Device.get_devices(session[:account_id])
    @geofences = Geofence.find(:all, :conditions => ["account_id = ?", session[:account_id]])
  end
  
  def insert_reading
    reading = Reading.new
    reading.device_id = params[:device_id]
    reading.latitude = params[:lat]
    reading.longitude = params[:lng]
    reading.speed = 0
    reading.save
    render :text => "ok"
  end
  
  def get_geofences_for_device
    @geofences = Geofence.find(:all, :conditions => ["device_id = ?", params[:device_id]], :order => "name asc")
    render :layout => false
  end
  
end

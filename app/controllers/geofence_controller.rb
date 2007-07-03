class GeofenceController < ApplicationController
  before_filter :authorize

  def index
    
  end

  def add
    if request.post?
      device = Device.get_device(params[:id], session[:account_id])
      if device.geofences.size < 3
        geofence = Geofence.new
        geofence.name = params[:name]
        geofence.bounds = params[:bounds]
        geofence.address = params[:address]
        geofence.device_id = device.id
        geofence.save
        flash[:message] = 'Geofence created succesfully'
      else
        flash[:message] = 'You can have a total of three geofences per device'
      end
        redirect_to :controller => 'geofence', :action => 'view', :id => device.id
    else
      @device = Device.get_device(params[:id], session[:account_id])
    end
  end
  
  def view
    @device = Device.get_device(params[:id], session[:account_id])
  end
  
end

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
        
        # Get the bounds parameters
        fence = params[:bounds].split(",")
        lat = fence[0]
        lng = fence[1]
        rad = fence[2].to_f * 1609.344 # 1 mile in meters

        # Call the middleware WS to set the geofence
        url = 'http://localhost:8080/webservice/simple/at.ws?cmd=AT%24GEOFNC=1,' + rad.to_s + ',' + lat + ',' + lng + '&device=' + device.imei
        resp = Net::HTTP.get_response(URI.parse(url))
        # Could be a sync problem, testing for now
        url = 'http://localhost:8080/webservice/simple/at.ws?cmd=AT%26w&device=' + device.imei
        resp = Net::HTTP.get_response(URI.parse(url))
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
  
  # TODO Protect this so the user can't specify an arbritray device and geofence id, tie it to account_id
  def edit
    if request.post?
      geofence = Geofence.find(params[:geofence_id], :conditions => ["device_id = ?", params[:device_id]])
      geofence.name = params[:name]
      geofence.bounds = params[:bounds]
      geofence.address = params[:address]
      geofence.save
      flash[:message] = 'Geofence updated successfully'
      redirect_to :controller => 'geofence', :action => 'view', :id => params[:device_id]
    else
      @geofence = Geofence.find(params[:geofence_id], :conditions => ["device_id = ?", params[:id ]])
    end
  end
  
  def delete
    if request.post?
      geofence = Geofence.find(params[:geofence_id], :conditions => ["device_id = ?", params[:device_id]])
      geofence.destroy
      flash[:message] = 'Geofence deleted successfully'
      redirect_to :controller => 'geofence', :action => 'view', :id => params[:device_id]
    end
  end
  
end

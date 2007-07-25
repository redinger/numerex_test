class GeofenceController < ApplicationController
  before_filter :authorize

  def index
    
  end

  def add
    if request.post?
      device = Device.get_device(params[:id], session[:account_id])
      if( !device.online?) 
        flash[:message] = 'Device appears offline, try again later'
        redirect_to :controller => 'geofence', :action => 'view', :id => device.id
        return
      end
      begin
        geofence = Geofence.new
        geofence.name = params[:name]
        geofence.bounds = params[:bounds]
        geofence.address = params[:address]
        geofence.device_id = device.id
        begin
          geofence.find_fence_num
        rescue
          flash[:message] = 'You can have a total of four geofences per device'
          redirect_to :controller => 'geofence', :action => 'view', :id => device.id
          return
        end
        
        # Get the bounds parameters
        fence = params[:bounds].split(",")
        lat = fence[0]
        lng = fence[1]
        rad = fence[2].to_f * 1609.344 # 1 mile in meters

        # Call the middleware WS to set the geofence
        Middleware_Gateway.send_AT_cmd('AT%24GEOFNC='+ geofence.fence_num.to_s + ',' + rad.round.to_s + ',' + lat + ',' + lng, device)
        Middleware_Gateway.send_AT_cmd('AT%26w', device)
        geofence.save!
        flash[:message] = 'Geofence created succesfully'
      rescue
        puts $!
        flash[:message] = 'Error creating geofence'
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
      begin
        geofence = Geofence.find(params[:geofence_id], :conditions => ["device_id = ?", params[:device_id]])
        device = Device.get_device(params[:device_id], session[:account_id])
        if( !device.online?) 
          flash[:message] = 'Device appears offline, try again later'
          redirect_to :controller => 'geofence', :action => 'view', :id => device.id
          return
        end
        geofence.name = params[:name]
        geofence.bounds = params[:bounds]
        geofence.address = params[:address]
        
        # Get the bounds parameters
        fence = params[:bounds].split(",")
        lat = fence[0]
        lng = fence[1]
        rad = fence[2].to_f * 1609.344 # 1 mile in meters
        
        Middleware_Gateway.send_AT_cmd('AT%24GEOFNC='+ geofence.fence_num.to_s + ',' + rad.round.to_s + ',' + lat + ',' + lng, device)
        Middleware_Gateway.send_AT_cmd('AT%26w', device)
        geofence.save
        flash[:message] = 'Geofence updated successfully'
      rescue
      puts $!
        flash[:message] = 'error updating geofence'
      end
      redirect_to :controller => 'geofence', :action => 'view', :id => params[:device_id]
    else
      @geofence = Geofence.find(params[:geofence_id], :conditions => ["device_id = ?", params[:id ]])
    end
  end
  
  def delete
    if request.post?
      begin
        geofence = Geofence.find(params[:geofence_id], :conditions => ["device_id = ?", params[:device_id]])
        device = Device.get_device(params[:device_id], session[:account_id])
        if( !device.online?) 
          flash[:message] = 'Device appears offline, try again later'
          redirect_to :controller => 'geofence', :action => 'view', :id => device.id
          return
        end
        Middleware_Gateway.send_AT_cmd('AT%24GEOFNC='+ geofence.fence_num.to_s + ',0,0,0', device)
        Middleware_Gateway.send_AT_cmd('AT%26w', device)
        geofence.destroy
        flash[:message] = 'Geofence deleted successfully'
      rescue
      puts $!
        flash[:message] = 'Error deleting geofence'
      end
      redirect_to :controller => 'geofence', :action => 'view', :id => params[:device_id]
    end
  end
  
end

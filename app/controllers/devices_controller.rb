
class DevicesController < ApplicationController
  before_filter :authorize
  
  def index
    @devices = Device.get_devices(session[:account_id])
  end
  
  # Device details view
  def view
    @device = Device.get_device(params[:id], session[:account_id])
    @device_names = Device.get_names(session[:account_id])
    @readings = Reading.find(:all, :conditions => ["device_id = ?", @device.id], :limit => 20, :order => "created_at desc")
    render :layout => 'application'
  end
  
  def choose_phone
    if (request.post? && params[:imei] != '')
      device = provision_device(params[:imei])
      if(!device.nil?)
        Text_Message_Webservice.send_message(params[:phone_number], "please click on http://www.db75.com/downloads/ublip.jad")
        redirect_to :controller => 'devices', :action => 'index'
      end
    end
  end
  
  # A device can provisioned
  def choose_MT
    if (request.post? && params[:imei] != '')
      device = provision_device(params[:imei])
      if(!device.nil?)
        redirect_to :controller => 'devices', :action => 'index'
      end
    end
  end
  
  # User can edit their device
  def edit
    if request.post?
      device = Device.find(params[:id], :conditions => ["account_id = ?", session[:account_id]])
      device.name = params[:name]
      device.imei = params[:imei]
      device.save
      flash[:message] = params[:name] + ' was updated successfully'
      redirect_to :controller => 'devices'
    else
      @device = Device.find(params[:id], :conditions => ["account_id = ?", session[:account_id]])  
    end
  end
  
  # User can delete their device
  def delete
    if request.post?
      device = Device.find(params[:id], :conditions => ["account_id = ?", session[:account_id]])
      device.update_attribute(:provision_status_id, 2) # Let's flag it for now instead of deleting it
      flash[:message] = device.name + ' was deleted successfully'
      redirect_to :controller => "devices"
    end
  end
  
  def provision_device(imei)
    device = Device.find_by_imei(imei) # Determine if device is already in system
        
    # Device is already in the system so let's associate it with this account
    if(device)
      if(device.provision_status_id == 0)
        device.account_id = session[:account_id]
        imei = params[:imei]
        device.name = params[:name]
        device.provision_status_id = 1
        device.save
        flash[:message] = params[:name] + ' was provisioned successfully'
      else
        flash[:message] = 'This device has already been added'
        return nil
      end
      # No device with this IMEI exists so let's add it
    else
      device = Device.new
      device.name = params[:name]
      device.imei = params[:imei]
      device.provision_status_id = 1
      device.account_id = session[:account_id]
      device.save
      flash[:message] = params[:name] + ' was created successfully'
    end
    return device
  end
end

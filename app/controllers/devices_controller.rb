class DevicesController < ApplicationController
  before_filter :authorize
  
  def index
    @devices = Device.get_devices(session[:account_id])
  end
  
  # User chooses a device to add
  # 1 Mobile phone tracker
  # 2 Personal tracker
  # 3 Fleet tracker
  
  # A device can provisioned
  def choose
    # User is associating device with account via IMEI
    if request.post?
      if(params[:imei] != '')
        device = Device.find_by_imei(params[:imei]) # Determine if device is already in system
        
        # Device is already in the system so let's associate it with this account
        if(device)
          if(device.provision_status_id == 0)
            device.account_id = session[:account_id]
            imei = params[:imei]
            device.name = params[:name]
            device.provision_status_id = 1
            device.save
            flash[:message] = params[:name] + ' was provisioned successfully'
            redirect_to :controller => 'devices'
          else
            flash[:message] = 'This device has already been added'
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
          redirect_to :controller => 'devices'
        end
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
      redirect_to :controller => "devices"
    else
      @device = Device.find(params[:id], :conditions => ["account_id = ?", session[:account_id]])  
    end
  end
  
  # User can delete their device
  def delete
    if request.post?
      device = Device.find(params[:id], :conditions => ["account_id = ?", session[:account_id]])
      device.update_attribute(:provision_status_id => 2) # Let's flag it for now instead of deleting it
      flash[:message] = device.name + ' was deleted successfully'
      redirect_to :controller => "devices"
    end
  end
end

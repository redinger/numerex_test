class DevicesController < ApplicationController
  #scaffold :device
  
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
        device = Device.find_by_imei(params[:imei])
        # Found the device
        if(device)
          if(device.provision_status_id == 0)
            device.account_id = session[:account_id]
            imei = params[:imei]
            device.name = 'Device ' + imei.slice(1, 4)
            device.provision_status_id = 1
            device.save
            flash[:message] = 'Your device was added successfully with a default name of ' + params[:imei]
            redirect_to :controller => 'devices'
          else
            flash[:message] = 'This device has already been provisioned'
          end
        # No device matching imei exists
        else
          flash[:message] = "We're sorry, there's no device with this IMEI currently in our system"
          flash[:imei] = params[:imei]
        end
      end
    end
  end
  
end

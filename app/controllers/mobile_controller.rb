class MobileController < ApplicationController
    
    def index        
      render :layout=>false
    end    
    
    def devices
      @devices = Device.get_devices(session[:account_id])
      render :layout=>false
    end
    
    def show_device
      @device=Device.find_by_id(params[:id])  
      render :layout=>false   
    end
    
end

class MobileController < ApplicationController    

    def index        
      
    end    
    
    def devices
      @devices = Device.get_devices(session[:account_id])      
    end
    
    def show_device
      @device=Device.find_by_id(params[:id])        
    end

    def view_all
        @marker_string = ""
        @range=('A'..'Z').to_a
        @all_devices_with_map = Device.get_devices(session[:account_id])      
    end
    
end

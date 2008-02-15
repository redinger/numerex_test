class HomeController < ApplicationController
  before_filter :authorize

  def index
    @devices = Device.get_devices(session[:account_id]) # Get devices associated with account
      
  end
  
  def map
   render :action => "home/map", :layout => "map_only"
   
 end
end

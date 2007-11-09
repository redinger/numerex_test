class ReadingsController < ApplicationController
 
  
  before_filter :authorize_http, :only => ['last']
  before_filter :authorize, :except => ['last']
  
  def recent
    if(params[:id].nil?)
      @devices = Device.get_devices(session[:account_id])
    else
      @devices = Device.find(:all, :conditions => ["id = ?", params[:id]])
    end
    
    # Prevent the layout from getting in the way
    render :layout => false
  end
  
  # Display last N readings for given device
  def last
    account = Account.find(:first, :conditions => ["subdomain = ?", request.host.split('.')[0]])
    device = Device.find(params[:id])
    if(device.account_id == account.id)
      @locations = Reading.find(:all, :conditions => ["device_id = ?", params[:id]], :limit => 1, :order => "created_at desc")
    else
      @locations = Array.new
    end
    render :layout => false
  end
  
  # Simple test for iGoogle integration
  def recent_public
    @readings = Reading.find(:all, :conditions => ["device_id = ?", params[:id]], :limit => 1, :order => "created_at desc")
    render_xml reading.to_xml
  end
end

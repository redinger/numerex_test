class ReadingsController < ApplicationController
  before_filter :authorize, :except => ['recent_public']
  
  #Get most recent readings for all devices
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
    # TODO fix this so that the user can only view readings for their device
    @readings = Reading.find(:all, :conditions => ["device_id = ?", params[:id]], :limit => 25, :order => "created_at desc")
    render :layout => false
  end
  
  # Simple test for iGoogle integration
  def recent_public
    reading = Reading.find(:all, :conditions => ["device_id = ?", params[:id]], :limit => 1, :order => "created_at desc")
    render_xml reading.to_xml
  end
end

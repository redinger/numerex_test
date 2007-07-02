class ReadingsController < ApplicationController
  before_filter :authorize
  
  #Get most recent readings for all devices
  def recent
    @devices = Device.get_devices(session[:account_id])
    # Prevent the layout from getting in the way
    render :layout => false
  end
  
  # Display last N readings for given device
  def last
    readings = Reading.find(:all, :conditions => ["device_id = ?", params[:id]], :limit => 25, :order => "created_at desc")
    render_xml readings.to_xml
  end
end

class ReadingsController < ApplicationController
  
  #Get most recent readings for all devices
  def recent
    readings = Device.find(:all)
    render_xml readings.to_xml
  end
  
  # Display last N readings for given device
  def last
    readings = Reading.find(:all, :conditions => ["device_id = ?", params[:id]], :limit => 25)
    render_xml readings.to_xml
  end
end

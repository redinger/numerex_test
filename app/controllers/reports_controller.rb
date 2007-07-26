class ReportsController < ApplicationController
  
  StopThreshold = 300 #stop event is triggered at 5min idle time
  ResultCount = 25 # Number of results per page
  DayInSeconds = 86400
  
  module StopEvent
    attr_reader :duration
    attr_writer :duration
  end
  
  def index
    @device_names = Device.get_names(session[:account_id])
  end
  
 def all
  unless params[:page]
    params[:page] = 1
  end
   
  page = params[:page].to_i
  end_time = Time.now.to_i # Current time in seconds
  start_time = end_time - (86400) # Start time in seconds
  @device_names = Device.get_names(session[:account_id])
  @readings = Reading.find(:all, :order => "created_at desc", 
              :conditions => ["device_id = ? and unix_timestamp(created_at) between ? and ?", params[:id], start_time, end_time], 
              :limit => ResultCount, 
              :offset => ((page-1)*ResultCount))
  @record_count = Reading.count('id', :conditions => ["device_id = ? and unix_timestamp(created_at) between ? and ?", params[:id], start_time, end_time])
end
  
  def stop
    unless params[:page]
      params[:page] = 1
    end
   
    page = params[:page].to_i
    @device_names = Device.get_names(session[:account_id])
    readings = Reading.find(:all, :order => "created_at desc", 
               :limit => ResultCount,
               :conditions => "event_type='startstop_et41' and device_id='#{params[:id]}'",
               :limit => ResultCount,
               :offset => ((page-1)*ResultCount))
               
    @stops = Array.new
    readings.each_index { |index|
                            if readings[index].speed==0
                              stopEvent = readings[index]
                              stopEvent.extend(StopEvent)
                              if(readings.size>index+1 && readings[index+1].speed > 0)
                                stopEvent.duration = readings[index+1].created_at - readings[index].created_at + StopThreshold
                              end
                              @stops.push stopEvent
                            end
                        }
  end
  
  def speed
    @readings = Reading.find(:all, :order => "created_at desc", :limit => 25, :conditions => "event_type='speeding_et40' and device_id='#{params[:id]}'")
  end

end

class ReportsController < ApplicationController
  
  StopThreshold = 300; #stop event is triggered at 5min idle time
  
  module StopEvent
    attr_reader :duration
    attr_writer :duration
  end
  
  def index
  end
  
  # Find all readings in descending order, limit 50
  def all_readings
    @readings = Reading.find(:all, :order => "created_at desc", :limit => 50, :conditions => "device_id='#{params[:id]}'")
    puts @readings.first.class
  end
  
  def stop
    readings = Reading.find(:all, :order => "created_at asc", :limit => 50, :conditions => "event_type='startstop_et41' and device_id='#{params[:id]}'")
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
    @readings = Reading.find(:all, :order => "created_at desc", :limit => 50, :conditions => "event_type='speeding_et40' and device_id='#{params[:id]}'")
  end

end

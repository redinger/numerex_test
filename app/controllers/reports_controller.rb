class ReportsController < ApplicationController
  
  module StopEvent
    attr_reader :duration
    attr_writer :duration
  end
  
  def index
  end
  
  # Find all readings in descending order, limit 50
  def all_readings
    @readings = Reading.find(:all, :order => "created_at desc", :limit => 50)
    puts @readings.first.class
  end
  
  def stop
    readings = Reading.find(:all, :order => "created_at asc", :limit => 50, :conditions => "event_type='stop_et41'")
    @stops = Array.new
    readings.each_index { |index|
                            if readings[index].speed==0
                              stopEvent = readings[index]
                              stopEvent.extend(StopEvent)
                              if(readings[index+1].speed > 0)
                                stopEvent.duration = readings[index+1].created_at - readings[index].created_at
                              end
                              @stops.push stopEvent
                            end
                        }
  end
  
  def start
    @readings = Reading.find(:all, :order => "created_at desc", :limit => 50, :conditions => "event_type='start'")
  end
  
  def speed
    @readings = Reading.find(:all, :order => "created_at desc", :limit => 50, :conditions => "event_type='speed'")
  end

end

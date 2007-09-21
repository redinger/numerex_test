require 'fastercsv'

class ReportsController < ApplicationController
  before_filter :authorize
  
  StopThreshold = 180 #stop event is triggered at 3min idle time
  ResultCount = 25 # Number of results per page
  DayInSeconds = 86400
  
  module StopEvent
    attr_reader :duration
    attr_writer :duration
  end
  
  def index
    @devices = Device.get_devices(session[:account_id])
  end
  
   def all
    unless params[:p]
      params[:p] = 1
    end 
    @page = params[:p].to_i
    @result_count = ResultCount
    
    unless params[:t]
      params[:t] = 1
    end
    timespan = params[:t].to_i
  
    end_time = Time.now.to_i # Current time in seconds
    start_time = end_time - (86400 * timespan) # Start time in seconds
    @device_names = Device.get_names(session[:account_id])
    @readings = Reading.find(:all, :order => "created_at desc", 
                :conditions => ["device_id = ? and unix_timestamp(created_at) between ? and ?", params[:id], start_time, end_time], 
                :limit => @result_count, 
                :offset => ((@page-1)*@result_count))
    @record_count = Reading.count('id', :conditions => ["device_id = ? and unix_timestamp(created_at) between ? and ?", params[:id], start_time, end_time])
  end
    
  def stop
    unless params[:p]
      params[:p] = 1
    end 
    @page = params[:p].to_i
    @result_count = ResultCount
    @stop_threshold = StopThreshold
    
    unless params[:t]
      params[:t] = 1
    end
    timespan = params[:t].to_i
    
    end_time = Time.now.to_i # Current time in seconds
    start_time = end_time - (86400 * timespan) # Start time in seconds
   
    @device_names = Device.get_names(session[:account_id])
    readings = Reading.find(:all, :order => "created_at asc", 
               :conditions => ["device_id = ? and event_type='startstop_et41' and unix_timestamp(created_at) between ? and ?", params[:id], start_time, end_time])
    @stops = Array.new
    filter_stops(readings)
    readings.each_index { |index|
                            currentReading = readings[index]
                            if readings[index].speed==0
                              stopEvent = readings[index]
                              stopEvent.extend(StopEvent)
                              if(readings.size>index+1 && readings[index+1].speed > 0)
                                stopEvent.duration = readings[index+1].created_at - readings[index].created_at + StopThreshold
                              else
                                nextReading = Reading.find(:first, :order => "created_at asc",
                                     :conditions => ["speed <> '0' and event_type <> 'startstop_et41' and device_id = ? and unix_timestamp(created_at) between ? and ?", params[:id], readings[index].created_at.to_i, end_time] )
                                if( !nextReading.nil? && nextReading.distance_to(readings[index], :units => :kms)<1)
                                  stopEvent.duration = nextReading.created_at - readings[index].created_at + StopThreshold
                                else
                                  next_moving_reading_after_stop = Reading.find(:first, :order => "created_at desc",
                                    :conditions => ["device_id = ? and unix_timestamp(created_at) between ? and ? and speed <> 0", params[:id], readings[index].created_at.to_i, Time.now.to_i])
                                  if(next_moving_reading_after_stop.nil?) 
                                    stopEvent.duration = -1
                                  end
                                  
                                end
                              end
                              @stops.push stopEvent
                            end
                        }
    @record_count = @stops.size   
    @stops.sort! {|r1,r2| r2.created_at <=> r1.created_at}
    @stops = @stops.slice!( (@page-1)*@result_count, @page*@result_count)
  end
  
  # Display geofence exceptions
  def geofence
    unless params[:p]
      params[:p] = 1
    end 
    @page = params[:p].to_i
    @result_count = ResultCount
    
    unless params[:t]
      params[:t] = 1
    end
    timespan = params[:t].to_i
    
    end_time = Time.now.to_i # Current time in seconds
    start_time = end_time - (86400 * timespan) # Start time in seconds
   
    @device_names = Device.get_names(session[:account_id])
    @readings = Reading.find(:all, :order => "created_at desc", 
               :limit => ResultCount,
               :conditions => ["device_id = ? and event_type like '%geofen%' and unix_timestamp(created_at) between ? and ?", params[:id], start_time, end_time],
               :limit => @result_count,
               :offset => ((@page-1)*@result_count))
    @record_count = Reading.count('id', :conditions => ["device_id = ? and event_type like '%geofen%' and unix_timestamp(created_at) between ? and ?", params[:id], start_time, end_time])
  end
  
  # Export report data to CSV - limiting to 100 readings
  def export
    
    unless params[:p]
      params[:p] = 1
    end
    
    # Determine report type so we know what filter to apply
    if params[:type] == 'all'
      event_type = '%'
    elsif params[:type] == 'stop'
      event_type = '%stop%'
    elsif params[:type] == 'geofen'
      event_type = '%geofen%'
    end
    
    # Get last 100 readings for given timeframe
    readings = Reading.find(:all, :order => "created_at desc",
                  :limit => 100,
                  :offset => ((params[:p].to_i-1)*ResultCount),
                  :conditions => ["device_id = ? and event_type like ?", params[:id], event_type])
                
    stream_csv do |csv|
      csv << ["latitude", "longitude", "address", "speed", "direction", "altitude", "event_type", "note", "when"]
      readings.each do |reading|
        csv << [reading.latitude, reading.longitude, reading.shortAddress, reading.speed, reading.direction, reading.altitude, reading.event_type, reading.note, reading.created_at]
      end
    end
  end
  
  def speed
    @readings = Reading.find(:all, :order => "created_at desc", :limit => 25, :conditions => "event_type='speeding_et40' and device_id='#{params[:id]}'")
  end
  
  #this method will delete any redundannt stops from readings
  def filter_stops(readings)
    anyDeletions = true;
    until anyDeletions==false
      anyDeletions = false;
      readings.each_index {|index| 
                           if(readings.size>index+1)
                              r1 = readings[index]
                              r2 = readings[index+1]
                              if(r1.speed==0 && r2.speed==0 && r1.distance_to(r2, :units => :kms) <= 0.2)
                                
                                next_moving_reading_after_stop = Reading.find(:first, :order => "created_at desc",
                                    :conditions => ["device_id = ? and unix_timestamp(created_at) between ? and ? and speed <> 0", r1.device_id, r1.created_at.to_i, r2.created_at.to_i])
                                
                                if( next_moving_reading_after_stop.nil? )
                                  readings.delete_at(index+1)
                                  anyDeletions = true
                                end
                              end
                          end
                        }
      end
  end
  
  private
    # Stream CSV content to the browser
    def stream_csv
       filename = params[:type] + "_" + params[:id] + ".csv"    
 
       # IE compat       
       if request.env['HTTP_USER_AGENT'] =~ /msie/i
         headers['Pragma'] = 'public'
         headers["Content-type"] = "text/plain" 
         headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
         headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
         headers['Expires'] = "0" 
       else
         headers["Content-Type"] ||= 'text/csv'
         headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
       end

      render :text => Proc.new { |response, output|
        csv = FasterCSV.new(output, :row_sep => "\r\n") 
        yield csv
      }
    end

end

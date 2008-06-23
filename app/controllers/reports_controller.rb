require 'fastercsv'

class ReportsController < ApplicationController
  before_filter :authorize
  before_filter :authorize_device, :except => ['index']
  
  StopThreshold = 180 #stop event is triggered at 3min idle time
  ResultCount = 25 # Number of results per page
  DayInSeconds = 86400
  NUMBER_OF_DAYS = 60
  
  module StopEvent
    attr_reader :duration
    attr_writer :duration
  end
  
  def index
    @devices = Device.get_devices(session[:account_id])
  end
  
  def all
     get_start_and_end_time# common method for setting start time and end time  Line no. 82       
     @device_names = Device.get_names(session[:account_id])
     @pages,@readings = paginate :readings, :order => "created_at desc", 
                :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_time, @end_time], 
                :per_page => ResultCount
     @record_count = Reading.count('id', :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_time, @end_time])                
  end

   
  def stop
    unless params[:page]
      params[:page] = 1
    end 
    @page = params[:page].to_i
    @result_count = ResultCount
    @stop_threshold = StopThreshold      
     get_start_and_end_time # common method for setting start time and end time Line no. 82 
    @device_names = Device.get_names(session[:account_id])
    stopevent_readings = Reading.find(:all, {:order => "created_at asc", :conditions => ["device_id = ? and event_type=\'startstop_et41\' and created_at between ? and ?", params[:id], @start_time, @end_time]})        
    filter_stops(stopevent_readings)
    @stops=get_stops(stopevent_readings)
    @record_count = @stops.size   
    @stops.sort! {|r1,r2| r2.created_at <=> r1.created_at}
    @pages,@stops = paginate_collection(:collection => @stops,:page => params[:page],:per_page => ResultCount)
  end
    
   def get_stops(stopevent_readings)
     @stops = Array.new  
     stopevent_readings.each_index { |index|
                            currentReading = stopevent_readings[index]
                            if stopevent_readings[index].speed==0
                              stopEvent = stopevent_readings[index]
                              stopEvent.extend(StopEvent)
                              if(stopevent_readings.size>index+1 && stopevent_readings[index+1].speed > 0)
                                stopEvent.duration = stopevent_readings[index+1].created_at - stopevent_readings[index].created_at + StopThreshold
                              else
                                next_moving_reading = Reading.find(:first, {:order => "created_at asc", :conditions => ["speed <> \'0\' and event_type <> \'startstop_et41\' and device_id = ? and created_at between ? and ?", params[:id], stopevent_readings[index].created_at.to_i, @end_time]})
                                if( !next_moving_reading.nil? && next_moving_reading.distance_to(stopevent_readings[index], :units => :kms)<1)
                                  stopEvent.duration = next_moving_reading.created_at - stopevent_readings[index].created_at + StopThreshold
                                else
                                  next_moving_reading_after_stop = Reading.find(:first, :order => "created_at desc",
                                    :conditions => ["device_id = ? and unix_timestamp(created_at) between ? and ? and speed <> 0", params[:id], stopevent_readings[index].created_at.to_i, Time.now.to_i])
                                  if(next_moving_reading_after_stop.nil? && index == stopevent_readings.size-1) 
                                    stopEvent.duration = -1
                                  end                                  
                                end
                              end
                              @stops.push stopEvent
                            end
                        }    
             return @stops           
   end
   
  # Display geofence exceptions
  def geofence
    get_start_and_end_time # common method for setting start time and end time Line no. 82 
    @geofences = Device.find(params[:id]).geofences # Geofences to display as overlays
    @device_names = Device.get_names(session[:account_id])
    @pages,@readings = paginate :readings, :order => "created_at desc", 
               :conditions => ["device_id = ? and event_type like '%geofen%' and created_at between ? and ?", params[:id], @start_time, @end_time],
               :per_page => ResultCount
    @record_count = Reading.count('id', :conditions => ["device_id = ? and event_type like '%geofen%' and created_at between ? and ?", params[:id], @start_time, @end_time])
  end

  def get_start_and_end_time
        params[:t] = 1
        if !params[:end_time1].nil?         
            if params[:end_time1].class.to_s == "String"
                @end_time = params[:end_time1].to_time
                @start_time =params[:start_time1].to_time             
            else    
                @end_time = get_time(params[:end_time1])
                @start_time = get_time(params[:start_time1])
             end
             @e=@end_time
             @s=@start_time
       else
         @from_normal=true  
         @end_time = Time.now   # Current time in seconds
         @start_time =  Time.now - (86400 * NUMBER_OF_DAYS)  # Start time in seconds
     end     
  end

  def get_time(time_inputs)
      date =''     
      time_inputs.each{|key,value|   date= date + value + " "}          
      date=date.strip.split(' ')
      time = "#{date[1]}-#{date[2]}-#{date[0]}"
      return time.to_time    
  end

  # Export report data to CSV 
  def export    
    unless params[:page]
      params[:page] = 1
    end    
    # Determine report type so we know what filter to apply
    if params[:type] == 'all'
      event_type = '%'
    elsif params[:type] == 'stop'
      event_type = '%stop%'
    elsif params[:type] == 'geofence'
      event_type = '%geofen%'
  end        
    start_time = params[:start_time].to_time
    end_time = params[:end_time].to_time    
    readings = Reading.find(:all, :order => "created_at desc",                  
                  :offset => ((params[:page].to_i-1)*ResultCount),
                  :conditions => ["device_id = ? and event_type like ? and created_at between ? and ?", params[:id], event_type,start_time,end_time])
     if params[:type]=='stop'
         filter_stops(readings)
         readings = get_stops(readings)
     end    
    stream_csv do |csv|
      csv << ["latitude", "longitude", "address", "speed", "direction", "altitude", "event_type", "note", "when"]
      readings.each do |reading|
        csv << [reading.latitude, reading.longitude, reading.shortAddress, reading.speed, reading.direction, reading.altitude, reading.event_type, reading.note, reading.created_at]
      end
    end
  end
  
  def speed
    @readings = Reading.find(:all, :order => "created_at desc", :limit => ResultCount, :conditions => "event_type='speeding_et40' and device_id='#{params[:id]}'")
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

 require 'fastercsv'
 ResultCount = 25 # Number of results per page
 
class ReportsController < ApplicationController
  before_filter :authorize
  before_filter :authorize_device, :except => ['index']
  DayInSeconds = 86400
  NUMBER_OF_DAYS = 7
  MAX_LIMIT=999 #max no. of results

  def index
    @devices = Device.get_devices(session[:account_id])
  end
  
  def all      
     get_start_and_end_time
     @device_names = Device.get_names(session[:account_id]) 
     @readings = Reading.find(:all,
                              :conditions => ["device_id = ? and created_at between ? and ?", 
                              params[:id],@start_time, @end_time],:order => "created_at desc", :limit => 25)                               
     @pages,@readings = paginate_collection(:collection => @readings,:page => params[:page],:per_page => ResultCount)   
     @record_count = Reading.count('id', 
                                   :conditions => ["device_id = ? and created_at between ? and ?", params[:id],@start_time, @end_time])
     @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data are going to be different in numbers.
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT     
  end
  
  def stop
    get_start_and_end_time
    @device_names = Device.get_names(session[:account_id])
    @stop_events = StopEvent.find(:all,
         :conditions => ["device_id = ? and created_at between ? and ?",
         params[:id],@start_time, @end_time], :order => "created_at desc", :limit => 25)
    @pages,@stop_events = paginate_collection(:collection => @stop_events,:page => params[:page],:per_page => ResultCount)   
    @record_count = StopEvent.count('id', :conditions => ["device_id = ? and date(created_at) between ? and ?", params[:id], @start_time, @end_time])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
     
  # Display geofence exceptions
  def geofence
    get_start_and_end_time # common method for setting start time and end time Line no. 82 
    @geofences = Device.find(params[:id]).geofences # Geofences to display as overlays
    @device_names = Device.get_names(session[:account_id])
    @readings = Reading.find(:all,
                              :conditions => ["device_id = ? and created_at between ? and ? and event_type like '%geofen%'",
                              params[:id],@start_time, @end_time], :order => "created_at desc", :limit => 25)            
     @pages,@readings = paginate_collection(:collection => @readings,:page => params[:page],:per_page => ResultCount)   
     @record_count = Reading.count('id', :conditions => ["device_id = ? and event_type like '%geofen%' and created_at between ? and ?", params[:id], @start_time, @end_time])
     @actual_record_count = @record_count
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT     
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
      time = "#{date[2]}-#{date[0]}-#{date[1]}"
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
     elsif params[:type] == 'geofence'
      event_type = '%geofen%'
     end        
     
     get_start_and_end_time # set the start and end time
     
     if params[:type]=='stop'
         stop_events = StopEvent.find(:all, {:order => "created_at desc",
                    :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_time, @end_time]})        
     else    
         readings = Reading.find(:all,
                      :order => "created_at desc",
                      :offset => ((params[:page].to_i-1)*ResultCount),
                      :limit=>MAX_LIMIT,
                      :conditions => ["device_id = ? and event_type like ? and created_at between ? and ?", params[:id],event_type,@start_time,@end_time])                                
     end   
              
    stream_csv do |csv|
         if params[:type] == 'stop'
            csv << ["Location","Stop Duration (m)", "When","Latitude", "Longitude"]  
         else    
            csv << ["Location","Speed (mph)", "When","Latitude", "Longitude","Event Type"]
        end 
     if params[:type] == 'stop'
       stop_events.each do |stop_event|                              
            local_time = Time.local(stop_event.created_at.year,stop_event.created_at.month,stop_event.created_at.day,stop_event.created_at.hour,stop_event.created_at.min,stop_event.created_at.sec)
            address = stop_event.reading.nil? ? "#{stop_event.latitude};#{stop_event.longitude}" : stop_event.reading.shortAddress
            csv << [address, ((stop_event.duration.to_s.strip.size > 0) ? stop_event.duration : 'Unknown'), local_time, stop_event.latitude, stop_event.longitude]
        end
     else
        readings.each do |reading|        
            local_time = Time.local(reading.created_at.year,reading.created_at.month,reading.created_at.day,reading.created_at.hour,reading.created_at.min,reading.created_at.sec)
            csv << [reading.shortAddress,reading.speed,local_time,reading.latitude, reading.longitude,reading.event_type ]
        end        
     end    
    end
  end
 
  def speed
    @readings = Reading.find(:all, :order => "created_at desc", :limit => ResultCount, :conditions => "event_type='speeding_et40' and device_id='#{params[:id]}'")
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

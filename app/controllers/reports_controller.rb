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
     @readings=Reading.paginate(:per_page=>ResultCount, :page=>params[:page],
                               :conditions => ["device_id = ? and created_at between ? and ?", 
                               params[:id],@start_time, @end_time],:order => "created_at desc")                             
     @record_count = Reading.count('id', 
                                   :conditions => ["device_id = ? and created_at between ? and ?", params[:id],@start_time, @end_time])
     @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data are going to be different in numbers.
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT         
  end
  
  def stop
    get_start_and_end_time
    @device_names = Device.get_names(session[:account_id])
    @stop_events = StopEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
          :conditions => ["device_id = ? and created_at between ? and ?",
           params[:id],@start_time, @end_time], :order => "created_at desc")
    @readings = @stop_events      
    @record_count = StopEvent.count('id', :conditions => ["device_id = ? and date(created_at) between ? and ?", params[:id], @start_time, @end_time])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
  
  def idle
    get_start_and_end_time
    @device_names = Device.get_names(session[:account_id])
    @idle_events = IdleEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
         :conditions => ["device_id = ? and created_at between ? and ?",
         params[:id],@start_time, @end_time], :order => "created_at desc")    
    @readings = @idle_events
    @record_count = IdleEvent.count('id', :conditions => ["device_id = ? and date(created_at) between ? and ?", params[:id], @start_time, @end_time])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
  
  def runtime
    get_start_and_end_time
    @device_names = Device.get_names(session[:account_id])
    @runtime_events = RuntimeEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
         :conditions => ["device_id = ? and created_at between ? and ?",
          params[:id],@start_time, @end_time], :order => "created_at desc")    
    @readings = @runtime_events
    @record_count = RuntimeEvent.count('id', :conditions => ["device_id = ? and date(created_at) between ? and ?", params[:id], @start_time, @end_time])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
     
  # Display geofence exceptions
  def geofence
    get_start_and_end_time # common method for setting start time and end time Line no. 82 
    @geofences = Device.find(params[:id]).geofences # Geofences to display as overlays
    @device_names = Device.get_names(session[:account_id])
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], 
                              :conditions => ["device_id = ? and created_at between ? and ? and event_type like '%geofen%'",
                              params[:id],@start_time, @end_time], :order => "created_at desc")                                             
     @record_count = Reading.count('id', :conditions => ["device_id = ? and event_type like '%geofen%' and created_at between ? and ?", params[:id], @start_time, @end_time])
     @actual_record_count = @record_count
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT     
  end

  def get_start_and_end_time
        params[:t] = 1
        if !params[:end_time1].nil?         
            if params[:end_time1].class.to_s == "String"
                get_UTC_format_time
             else                
                @end_time = get_time(params[:end_time1])
                @start_time = get_time(params[:start_time1])
             end
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

     # Name of the csv file
     @filename = params[:type] + "_" + params[:id] + ".csv"  
     
     csv_string = FasterCSV.generate do |csv|
         if params[:type] == 'stop'
            csv << ["Location","Stop Duration (m)","Started","Latitude","Longitude"]
         else    
            csv << ["Location","Speed (mph)","Started","Latitude","Longitude","Event Type"]
        end 
         if params[:type] == 'stop'
           stop_events.each do |stop_event|                                              
               local_time = stop_event.get_local_time(stop_event.created_at.in_time_zone.inspect)
               address = stop_event.reading.nil? ? "#{stop_event.latitude};#{stop_event.longitude}" : stop_event.reading.shortAddress
               csv << [address,((stop_event.duration.to_s.strip.size > 0) ? stop_event.duration : 'Unknown'),local_time, stop_event.latitude,stop_event.longitude]
            end
         else
            readings.each do |reading|        
               local_time = reading.get_local_time(reading.created_at.in_time_zone.inspect)
                csv << [reading.shortAddress,reading.speed,local_time,reading.latitude,reading.longitude,reading.event_type]
            end        
         end    
     end
     
     send_data csv_string,
         :type => 'text/csv; charset=iso-8859-1; header=present',
         :disposition => "attachment; filename=#{@filename}"
  end
 
  def speed
    @readings = Reading.find(:all, :order => "created_at desc", :limit => ResultCount, :conditions => "event_type='speeding_et40' and device_id='#{params[:id]}'")
  end
   # Stream CSV content to the browser
  private    

    def get_UTC_format_time
      if params[:end_time1].include?("UTC")
        @end_time = params[:end_time1].to_time
        @start_time =params[:start_time1].to_time
      else
       @end_time = set_time(params[:end_time1])      # Helper Method
       @start_time = set_time(params[:start_time1])
     end     
  end

  def set_time(params_value)      
    date = params_value.gsub(/[a-z]/,' ').squeeze(' ').split    
    time = Time.utc(date[2].to_i,date[0].to_i, date[1].to_i,0,0,0) 
  end

end

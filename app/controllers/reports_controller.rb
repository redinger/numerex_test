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
     get_start_and_end_date
     @device_names = Device.get_names(session[:account_id]) 
     @readings=Reading.paginate(:per_page=>ResultCount, :page=>params[:page],
                               :conditions => ["device_id = ? and date(created_at) between ? and ?", 
                               params[:id],@start_date, @end_date],:order => "created_at desc")                             
     @record_count = Reading.count('id', 
                                   :conditions => ["device_id = ? and date(created_at) between ? and ?", params[:id],@start_date, @end_date])
     @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data are going to be different in numbers.
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT         
  end
  
  def stop
    get_start_and_end_date
    @device_names = Device.get_names(session[:account_id])
    @stop_events = StopEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
          :conditions => ["device_id = ? and date(created_at) between ? and ?",
           params[:id],@start_date, @end_date], :order => "created_at desc")
    @readings = @stop_events      
    @record_count = StopEvent.count('id', :conditions => ["device_id = ? and date(created_at) between ? and ?", params[:id], @start_date, @end_date])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
  
  def idle
    get_start_and_end_date
    @device_names = Device.get_names(session[:account_id])
    @idle_events = IdleEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
         :conditions => ["device_id = ? and date(created_at) between ? and ?",
         params[:id],@start_date, @end_date], :order => "created_at desc")    
    @readings = @idle_events
    @record_count = IdleEvent.count('id', :conditions => ["device_id = ? and date(created_at) between ? and ?", params[:id], @start_date, @end_date])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
  
  def runtime
    get_start_and_end_date
    @device_names = Device.get_names(session[:account_id])
    @runtime_events = RuntimeEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
         :conditions => ["device_id = ? and date(created_at) between ? and ?",
          params[:id],@start_date, @end_date], :order => "created_at desc")    
    @readings = @runtime_events
    @record_count = RuntimeEvent.count('id', :conditions => ["device_id = ? and date(created_at) between ? and ?", params[:id], @start_date, @end_date])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
     
  # Display geofence exceptions
  def geofence
    get_start_and_end_date # common method for setting start date and end date Line no. 82 
    @geofences = Device.find(params[:id]).geofences # Geofences to display as overlays
    @device_names = Device.get_names(session[:account_id])
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], 
                              :conditions => ["device_id = ? and date(created_at) between ? and ? and event_type like '%geofen%'",
                              params[:id],@start_date, @end_date], :order => "created_at desc")                                             
     @record_count = Reading.count('id', :conditions => ["device_id = ? and event_type like '%geofen%' and date(created_at) between ? and ?", params[:id], @start_date, @end_date])
     @actual_record_count = @record_count
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT     
  end

  def get_start_and_end_date     
        if !params[:end_date].nil?         
             if params[:end_date].class.to_s == "String"
                @end_date = params[:end_date].to_date
                @start_date = params[:start_date].to_date
             else                
                @end_date = get_date(params[:end_date])
                @start_date = get_date(params[:start_date])
             end
       else
         @from_normal=true  
         @end_date = Date.today   
         @start_date =  Date.today -  NUMBER_OF_DAYS  
     end     
  end

  def get_date(date_inputs)
      date =''     
      date_inputs.each{|key,value|   date= date + value + " "}          
      date=date.strip.split(' ')
      date = "#{date[2]}-#{date[0]}-#{date[1]}".to_date
      return date
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
     get_start_and_end_date # set the start and end date
     if params[:type]=='stop'
         events = StopEvent.find(:all, {:order => "created_at desc",
                    :conditions => ["device_id = ? and date(created_at) between ? and ?", params[:id], @start_date, @end_date]})        
     elsif params[:type] == 'idle'
         events = IdleEvent.find(:all, {:order => "created_at desc",
                    :conditions => ["device_id = ? and date(created_at) between ? and ?", params[:id], @start_date, @end_date]})                
     elsif params[:type] =='runtime'   
         events = RuntimeEvent.find(:all, {:order => "created_at desc",
                    :conditions => ["device_id = ? and date(created_at) between ? and ?", params[:id], @start_date, @end_date]})                        
     else    
         readings = Reading.find(:all,
                      :order => "created_at desc",
                      :offset => ((params[:page].to_i-1)*ResultCount),
                      :limit=>MAX_LIMIT,
                      :conditions => ["device_id = ? and event_type like ? and date(created_at) between ? and ?", params[:id],event_type,@start_date,@end_date])                                
     end   
     # Name of the csv file
     @filename = params[:type] + "_" + params[:id] + ".csv"      
     csv_string = FasterCSV.generate do |csv|
         if ['stop','idle','runtime'].include?(params[:type]) 
           csv << ["Location","#{params[:type].capitalize} Duration (m)","Started","Latitude","Longitude"]  
           events.each do |event|                                              
               local_time = event.get_local_time(event.created_at.in_time_zone.inspect)
               address = event.reading.nil? ? "#{event.latitude};#{event.longitude}" : event.reading.shortAddress
               csv << [address,((event.duration.to_s.strip.size > 0) ? event.duration : 'Unknown'),local_time, event.latitude,event.longitude]
            end
         else
            csv << ["Location","Speed (mph)","Started","Latitude","Longitude","Event Type"] 
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
 
end

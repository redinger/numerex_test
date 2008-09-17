require 'fastercsv'
ResultCount = 25 # Number of results per page

class ReportsController < ApplicationController  
  before_filter :authorize
  before_filter :authorize_device, :except => ['index','group_devices']
  DayInSeconds = 86400
  NUMBER_OF_DAYS = 7
  MAX_LIMIT = 999 # Max number of results
 
  def index      
      @device_string=""
      if request.post?
           @from_search = true                             
           search_devices  #private method for searching
           @all_groups = Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
           @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                           
           @devices.each{|device| @device_string+="#{device.id},"}           
      else    
          @from_reports = true
          @all_groups = Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
          @devices = Device.get_devices(session[:account_id]) # Get devices associated with account                  
          @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                           
      end    
  end
    
   def group_devices     
         @group = Group.find_by_id(params[:id], :conditions=>['account_id=?',session[:account_id]])
         if !@group.nil? || params[:id] == 'default'
             params[:id] == 'default' ? @group_name = 'Default' : @group_name = @group.name         
             @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id = 1',session[:account_id]], :order=>'name')                     
             if params[:id] !='default'
                @devices = Device.find(:all, :conditions => ['group_id=? and provision_status_id = 1 and account_id = ?', params[:id],session[:account_id]], :order => 'name')         
             else
                 @from_default = true
             end
             @all_groups = Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
         else
             redirect_to :controller=>'home'
         end    
   end
   

  def all               
     get_start_and_end_date
     @device = Device.find(params[:id])     
     @device_names = Device.get_names(session[:account_id]) 
     @readings=Reading.paginate(:per_page=>ResultCount, :page=>params[:page],
                               :conditions => ["device_id = ? and created_at between ? and ?", 
                               params[:id],@start_dt_str, @end_dt_str],:order => "created_at desc")                             
     @record_count = Reading.count('id', 
                                   :conditions => ["device_id = ? and created_at between ? and ?", params[:id],@start_dt_str, @end_dt_str])
     @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data are going to be different in numbers.
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
  def stop
    get_start_and_end_date
    @device = Device.find(params[:id])     
    @device_names = Device.get_names(session[:account_id]) 
    @stop_events = StopEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
          :conditions => ["device_id = ? and created_at between ? and ?",
           params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")
    @readings = @stop_events      
    @record_count = StopEvent.count('id', :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
 

  def idle
    get_start_and_end_date
    @device = Device.find(params[:id])     
    @device_names = Device.get_names(session[:account_id]) 
    @idle_events = IdleEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
         :conditions => ["device_id = ? and created_at between ? and ?",
         params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")    
    @readings = @idle_events
    @record_count = IdleEvent.count('id', :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
  

  def runtime
    get_start_and_end_date
    @device = Device.find(params[:id])     
    @device_names = Device.get_names(session[:account_id]) 
    @runtime_events = RuntimeEvent.paginate(:per_page=>ResultCount, :page=>params[:page],
         :conditions => ["device_id = ? and created_at between ? and ?",
          params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")    
    @readings = @runtime_events
    @record_count = RuntimeEvent.count('id', :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
    @actual_record_count = @record_count # this is because currently we are putting  MAX_LIMIT on export data so export and view data going to be diferent in numbers.
    @record_count = MAX_LIMIT if @record_count > MAX_LIMIT
  end
     
  # Display geofence exceptions
  def geofence
    get_start_and_end_date 
    @device = Device.find(params[:id])     
    @device_names = Device.get_names(session[:account_id])  
    @geofences = Device.find(params[:id]).geofences # Geofences to display as overlays    
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], 
                              :conditions => ["device_id = ? and created_at between ? and ? and event_type like '%geofen%'",
                              params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")                                             
     @record_count = Reading.count('id', :conditions => ["device_id = ? and event_type like '%geofen%' and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
     @actual_record_count = @record_count
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT     
  end
     
  # Display gpio1 events
  def gpio1
    get_start_and_end_date 
    @device = Device.find(params[:id])
    @device_names = Device.get_names(session[:account_id]) 
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], 
                              :conditions => ["device_id = ? and created_at between ? and ? and gpio1 is not null",
                              params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")                                             
     @record_count = Reading.count('id', :conditions => ["device_id = ? and gpio1 is not null and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
     @actual_record_count = @record_count
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT     
  end
     
  # Display gpio2 events
  def gpio2
    get_start_and_end_date 
    @device = Device.find(params[:id])
    @device_names = Device.get_names(session[:account_id])
    @readings = Reading.paginate(:per_page=>ResultCount, :page=>params[:page], 
                              :conditions => ["device_id = ? and created_at between ? and ? and gpio2 is not null",
                              params[:id],@start_dt_str, @end_dt_str], :order => "created_at desc")                                             
     @record_count = Reading.count('id', :conditions => ["device_id = ? and gpio2 is not null and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str])
     @actual_record_count = @record_count
     @record_count = MAX_LIMIT if @record_count > MAX_LIMIT     
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
     get_start_and_end_date
     if params[:type]=='stop'
         events = StopEvent.find(:all, {:order => "created_at desc",
                    :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str]})        
     elsif params[:type] == 'idle'
         events = IdleEvent.find(:all, {:order => "created_at desc",
                    :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str]})                
     elsif params[:type] =='runtime'   
         events = RuntimeEvent.find(:all, {:order => "created_at desc",
                    :conditions => ["device_id = ? and created_at between ? and ?", params[:id], @start_dt_str, @end_dt_str]})                        
     else    
         readings = Reading.find(:all,
                      :order => "created_at desc",
                      :offset => ((params[:page].to_i-1)*ResultCount),
                      :limit=>MAX_LIMIT,
                      :conditions => ["device_id = ? and event_type like ? and created_at between ? and ?", params[:id],event_type,@start_dt_str,@end_dt_str])                                
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
 
private

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
     @start_dt_str = @start_date.to_s + ' 00:00:00'
     @end_dt_str   = @end_date.to_s + ' 23:59:59'
  end

  def get_date(date_inputs)
      date =''     
      date_inputs.each{|key,value|   date= date + value + " "}          
      date=date.strip.split(' ')
      date = "#{date[2]}-#{date[0]}-#{date[1]}".to_date
      return date
  end

   def search_devices        
       @devices=[]  
       if params[:status]=='prov'
           search(1)           
       else
           search(0)
       end    
   end

   def search(provisionStatusId)
        # search by AND
        if (params[:device_name] !="Enter device name" && params[:device_address] !="State / Location" && params[:device_group] !="")
             if params[:device_group]=='default'
               @all_devices = Device.find(:all, :conditions=>['account_id=? and provision_status_id=? and name like ? and group_id is NULL',session[:account_id],provisionStatusId,"%#{params[:device_name]}%"])  
             else    
               @all_devices = Device.find(:all, :conditions=>['account_id=? and provision_status_id=? and name like ? and group_id = ?',session[:account_id],provisionStatusId,"%#{params[:device_name]}%",params[:device_group]])
             end  
            @all_devices.each do |device|
                if (!device.readings[0].nil? && device.readings[0].shortAddress.downcase =~ /#{params[:device_address].downcase}/) 
                   @devices << device 
                end    
            end                
            @from_condition_1 = true
        end
        
        if (params[:device_name] !="Enter device name" && params[:device_group] !="" && params[:device_address] =="State / Location")                
            if params[:device_group]=='default'
              @devices = Device.find(:all, :conditions=>['account_id=? and provision_status_id=? and name like ? and group_id is NULL',session[:account_id],provisionStatusId,"%#{params[:device_name]}%"])  
            else    
              @devices = Device.find(:all, :conditions=>['account_id=? and provision_status_id=? and name like ? and group_id = ?',session[:account_id],provisionStatusId,"%#{params[:device_name]}%",params[:device_group]])
            end 
             @from_condition_2 = true
         end      
         
        #search by OR
        if (!@from_condition_1 && !@from_condition_2 ) && (params[:device_name] !="Enter device name" || params[:device_address] !="State / Location" || params[:device_group] !="")                
             if params[:device_group]=='default' 
                @all_devices = Device.find(:all, :conditions=>['account_id=? and provision_status_id=? and name like ? or (group_id is NULL and provision_status_id=?)',session[:account_id],provisionStatusId,"%#{params[:device_name]}%",provisionStatusId]) 
             else    
                @all_devices = Device.find(:all, :conditions=>['account_id=? and provision_status_id=? and name like ? or group_id = ?',session[:account_id],provisionStatusId,"%#{params[:device_name]}%",params[:device_group]])
             end   
            if params[:device_group] =="" && params[:device_name] =="Enter device name" 
                @all_devices = Device.find(:all, :conditions=>['account_id=? and provision_status_id=?',session[:account_id],provisionStatusId]) 
                @all_devices.each do |device|
                    if (!device.readings[0].nil? && device.readings[0].shortAddress.downcase =~ /#{params[:device_address].downcase}/) 
                       @devices << device 
                    end                    
                end    
            else
                 @devices = @all_devices    
             end  
           @from_condition_3 = true  
       end        
           
       if !@from_condition_1 && !@from_condition_2 && !@from_condition_3
           @devices = Device.find(:all, :conditions => ['provision_status_id = ? and account_id = ?',provisionStatusId,session[:account_id]], :order => 'name')         
       end    
       
       if params[:reports_within] !=""           
           start_date = Date.today - params[:reports_within].to_i 
           end_date = Date.today 
           temp_stroage_for_devices=[]
           @devices.each do |device| 
               if !device.readings[0].nil?
                   if (device.readings[0].created_at.to_date >= start_date && device.readings[0].created_at.to_date <= end_date)
                     temp_stroage_for_devices << device  
                    end
               end
           end        
           @devices = temp_stroage_for_devices
       end
   end

end

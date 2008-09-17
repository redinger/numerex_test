module ReportsHelper
  def minutes_to_hours(min)
    if min < 60
      (min % 60).to_s + " min"
    else
      hr = min / 60
      hr.to_s + (hr == 1 ? " hr" : " hrs") + ", " + (min % 60).to_s + " min"
    end
  end
  
  def total_miles(readings)
    total = 0
    for i in (0..readings.size)
      if i < readings.size-1
        total = total + readings[i].distance_to(readings[i+1])
      end
    end
    total
  end

  def update_readings_automatically?
    params[:action] == "index" || "group_devices"
  end
  def show_device(device)
    content = ""
    content << %(<tr class="#{cycle('dark_row', 'light_row')}" id="row#{device.id}"> <td>)                              
    content << %(<a href="/reports/all/#{device.id}">#{device.name}</a></td><td>)    
    if !device.readings.empty? 
      content << %(#{device.readings[0].shortAddress})
    else 
      content << %(N/A)
    end 
    content << %(</td><td>)    
    if !device.readings.empty? 
      content << %(reported #{time_ago_in_words device.readings[0].created_at} ago )
    else 
      content << %(no report yet) 
    end  
    content << %(</td>
      </tr>)
    content 
   end    

  def show_device_for_reports(device,from_flag)
    content = ""
    content << %(<tr class="#{cycle('light_row', 'dark_row')}" id="row#{device.id}") 
    if (from_flag=='true')
         content << %( style="display:none;")
     end
     
    content << %(><td>)
    if !device.readings.empty?
        content << %(<a href="javascript:centerMap(#{device.id});highlightRow(#{device.id});" title="Center map on this device" class="link-all1">#{device.name}</a>)
        content << %( <a href="/reports/all/#{device.id}" title="View device details" class="link-all1">(details)</a>)
    else
        content << %(#{device.name} <a href="/reports/all/#{device.id}" title="View device details" class="link-all1">(details)</a>)
    end    
    content << %(</td>)
    content << %(<td>)
    if !device.readings.empty?
       content << %(#{device.readings[0].shortAddress})
    else
       content << %(N/A) 
    end    
    content << %(</td>)        
     content << %(<td)
         if (from_flag =='false')
           content << %( style="display:none;")
         end
         content << %(>)
         if current_account.show_runtime
             content << %(#{device.last_status_string})     
         end        
         content << %(</td>)
         
       content << %(<td>)
       if !device.readings.empty?
           content << %(#{time_ago_in_words device.readings[0].created_at} ago)
       else
           content << %(N/A)
       end    
      content << %(</td>)
      content << %(</tr>)
      
    content 
   end    
end

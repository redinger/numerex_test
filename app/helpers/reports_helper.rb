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


  def show_device(device)
    content = ""
    content << %(<tr class="#{cycle('dark_row', 'light_row')}" id="row#{device.id}"> <td>)                              
    content << %(<a href="/reports/all/#{device.id}">#{device.name}</a></td><td>)    
    if device.latest_gps_reading 
      content << %(#{device.latest_gps_reading.short_address})
    else 
      content << %(N/A)
    end 
    content << %(</td><td>)    
    if device.latest_gps_reading 
      content << %(reported #{time_ago_in_words device.latest_gps_reading.created_at} ago )
    else 
      content << %(no report yet) 
    end  
    content << %(</td>
      </tr>)
    content 
   end    

end

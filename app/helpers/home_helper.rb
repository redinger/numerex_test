module HomeHelper

  def update_readings_automatically?
    params[:action] == "index" || "statistics" || "maintenance" || "show_devices"
  end

  def decide_action 
     content=""  
     if @from_reports
         content << %(select_action(this,'from_reports'))
     elsif @from_statistics
         content << %(select_action(this,'from_statistics'))
     elsif @from_maintenance
         content << %(select_action(this,'from_maintenance'))
     elsif @from_devices || @from_search
         content << %(select_action(this,'from_devices'))
     else    
         content << %(select_action(this,'from_home'))
     end
     content
 end
 
  def show_device(device)
    content = ""
    content << %(<tr class="#{cycle('dark_row', 'light_row')}" id="row#{device.id}"> <td>)
    if device.latest_gps_reading
      content << %(<a href="javascript:centerMap(#{device.id});highlightRow(#{device.id});" title="Center map on this device" class="link-all1">#{device.name}</a>)
    else
      content << %(#{device.name})
    end      
    content << %(</td>
    <td style="font-size:11px;">
      <a href="/reports/all/#{device.id}" title="View device details" class="link-all1">details</a>
    </td><td>)
    if device.latest_gps_reading
      content << %(#{device.latest_gps_reading.short_address})
    else
      content << %(N/A)
    end
    content << %(</td>)

    if current_account.show_runtime
      content << %(<td>)
      content << %(#{device.last_status_string})
      content << %(</td>)
    end

    content << %(<td>)
    if device.latest_gps_reading
      content << %(#{time_ago_in_words device.latest_gps_reading.created_at} ago)
    else
      content << %(N/A)
    end
    content << %(</td>)
    content << %(</tr>)

    content
  end

  def show_statistics(device)
    # TODO replace with real data
    @stop_total ||= 1
    @idle_total ||= 2.0
    @runtime_total ||= 40.0
    idle_percentage = sprintf("%2.2f",@idle_total/@runtime_total * 100)
    runtime_percentage = sprintf("%2.2f",@runtime_total/(7 * 24) * 100)

    content = ""
    content << %(<tr class="#{cycle('dark_row', 'light_row')}" id="row#{device.id}"> <td>)
    if device.latest_gps_reading
      content << %(<a href="javascript:centerMap(#{device.id});highlightRow(#{device.id});" title="Center map on this device" class="link-all1">#{device.name}</a>)
    else
      content << %(#{device.name})
    end
    content << %(</td>
    <td style="font-size:11px;">
      <a href="/reports/all/#{device.id}" title="View device details" class="link-all1">details</a>
    </td>
    <td style="text-align:right;">#{@stop_total}<td style="text-align:right;">#{@idle_total}<td style="text-align:right;">#{idle_percentage}<td style="text-align:right;">#{@runtime_total}<td style="text-align:right;">#{runtime_percentage})

    @stop_total += 1
    @idle_total += 2
    @runtime_total -= 2

    content
  end

  def show_maintenance(device)
    # TODO replace with real data
    @counter ||= 1
    case @counter
      when 1
      maintenance_date = device.created_at.strftime("%Y-%m-%d")
      next_required = "after 103 more hours"
      maintenance_status = "OK"
      status_color = "style='text-align:center;color:white;background-color:green;'"
      when 2
      maintenance_date = device.created_at.strftime("%Y-%m-%d")
      next_required = (Time.now + (60 * 60 * 24 * 60)).strftime("%Y-%m-%d")
      maintenance_status = "OK"
      status_color = "style='text-align:center;color:white;background-color:green;'"
      when 3
      maintenance_date = device.created_at.strftime("%Y-%m-%d")
      next_required = "after 5 more hours"
      maintenance_status = "PENDING"
      status_color = "style='text-align:center;background-color:yellow;'"
      when 4
      maintenance_date = device.created_at.strftime("%Y-%m-%d")
      next_required = "30 hours ago"
      maintenance_status = "PAST DUE"
      status_color = "style='text-align:center;color:white;background-color:red;'"
    else
      maintenance_date = "Unspecified"
      next_required = "&nbsp;"
      maintenance_status = "&nbsp;"
    end
    @counter += 1

    content = ""
    content << %(<tr class="#{cycle('dark_row', 'light_row')}" id="row#{device.id}"> <td>)
    if device.latest_gps_reading
      content << %(<a href="javascript:centerMap(#{device.id});highlightRow(#{device.id});" title="Center map on this device" class="link-all1">#{device.name}</a>)
    else
      content << %(#{device.name})
    end
    content << %(</td>
    <td style="font-size:11px;">
      <a href="/reports/all/#{device.id}" title="View device details" class="link-all1">details</a>
    </td>
    <td>#{maintenance_date}<td>#{next_required}<td #{status_color}><b>#{maintenance_status}</b>)

    content
  end

end

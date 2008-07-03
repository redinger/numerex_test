module MobileHelper

   def show_device(device,flag)
        content = ""
        content << %(<li>)
        if device.recent_reading_id != 0
            content << %(<strong>#{@range[@all_devices_with_map.index(device)] }: </strong>) if !flag
            content << %(<a href="/mobile/show_device/#{device.id}" title="Center map on this device">#{device.name}</a>)
            content << %(&nbsp;&nbsp;(#{time_ago_in_words device.readings[0].created_at} ago)<br/>)
            content << %(#{device.readings[0].shortAddress})
            @center= "37.0625, -95.677068" if @center == "" if !flag
            @marker_string = @marker_string + "#{device.readings[0].latitude},#{device.readings[0].longitude},#{MAP_MARKER_COLOR[ device.icon_id-1]}#{@range[@all_devices_with_map.index(device)].downcase}%7C" if !flag           
        else
            content << %(#{device.name})
            content << %( &nbsp;N/A<br/>)
            content << %(N/A)
        end    
        content << %(</li>)
    end    
    
end

module HomeHelper

   def show_device(device)
       content = ""
        content << %(<tr class="#{cycle('dark_row', 'light_row')}" id="row#{device.id}"> <td>)                          
         if device.recent_reading_id != 0
            content << %(<a href="javascript:centerMap(#{device.id});highlightRow(#{device.id});" title="Center map on this device" class="link-all1">#{device.name}</a>)
         else
             content << %(#{device.name})
         end 
         content << %(</td>
      <td style="font-size:11px;">
        <a href="/reports/all/#{device.id}" title="View device details" class="link-all1">details</a>
      </td>
      <td>) 
            if device.recent_reading_id != 0 
              content << %(#{device.readings[0].shortAddress})
            else 
              content << %(N/A)
             end 
             content << %(</td>
      <td>)
          if device.recent_reading_id != 0 
              content << %(#{time_ago_in_words device.readings[0].created_at} ago )
          else 
              content << %(N/A) 
          end
          content << %(</td>
                     </tr>)
       content 
   end    
   
end

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def box_pagination_links(paginator, options={})
    options.merge!(ActionView::Helpers::PaginationHelper::DEFAULT_OPTIONS) {|key, old, new| old}
    window_pages = paginator.current.window(options[:window_size]).pages

    return if window_pages.length <= 1 unless
    options[:link_to_current_page]
    first, last = paginator.first, paginator.last

    returning html = '' do

      if options[:always_show_anchors] and not window_pages[0].first?
        html<< link_to("&laquo; First",  { options[:name] => first }.update(options[:params] ))
        html << ' '
      end

      if paginator.current.previous
        html<< link_to("&laquo; Prev",  { options[:name] => paginator.current.previous }.update(options[:params] ))
      else
        html << "<span class='nextprev'>&laquo; Prev</span>"
      end

      window_pages.each do |page|
        if paginator.current == page && !options[:link_to_current_page]
          html << "<span class='current'>#{page.number.to_s}</span>"
        else
          html<< link_to(page.number, { options[:name] => page }.update(options[:params] ))
        end
        #~ html << ' '
      end

      if paginator.current.next
        html<< link_to("Next &raquo",  { options[:name] => paginator.current.next }.update(options[:params] ))
      else
        html << "<span class='nextprev'>Next &raquo;</span>"
      end

      if options[:always_show_anchors] && !window_pages.last.last?
        html<< link_to("Last &raquo;",  { options[:name] => last }.update( options[:params]))
      end

    end

  end

  def get_flash_error
    flash_string=""
    self.errors.each_full do | err |
      flash_string << err + "<br/>"
    end
    return flash_string
  end

  def display_result_count(page,total_count,per_page)
    page = 1 if page.to_i == 0
    if (total_count <= per_page)
      return "Displaying 1 - #{total_count} of #{total_count}"
    else
      approximate_number=per_page*page
      if (approximate_number > total_count )
        end_limit = total_count
        start_limit = total_count - ( total_count%per_page)
        return "Displaying #{start_limit+1} - #{end_limit} of #{total_count}"
      else
        start_limit = approximate_number - per_page
        return "Displaying #{start_limit+1} - #{approximate_number} of #{total_count}"
      end
    end
  end

  def get_local_time(reading_time)
    time_in_array = reading_time.split(' ')
    return "#{time_in_array[0]} #{time_in_array[2]} #{time_in_array[1]} #{time_in_array[3]} #{time_in_array[4]}"
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
    content << %(</td><td >)
    content << %(<a href="/devices/edit/#{device.id}" title="Edit properties for this device">Edit</a> |
					  <a href="#{view_path(:id=>device.id)}" title="Create and edit geofences for this device">Geofences</a>
				</td></tr>)
    content
  end
  
  def latest_status_html(device)
    results = device.latest_status
    return '-' unless results
    title = nil
    uri = nil
    label = results[1]
    case results[0]
      when Device::REPORT_TYPE_ALL
        title = "View all readings"
        uri = "/reports/all/#{device.id}"
      when Device::REPORT_TYPE_TRIP
        title = "View trip report"
        uri = "/reports/trip/#{device.id}"
      when Device::REPORT_TYPE_STOP
        title = "View stop report"
        uri = "/reports/stop/#{device.id}"
      when Device::REPORT_TYPE_IDLE 
        title = "View idle report"
        uri = "/reports/idle/#{device.id}"
      when Device::REPORT_TYPE_SPEEDING
        title = "View speeding report"
        uri = "/reports/speeding/#{device.id}"
        label = "<b><i>#{label}</i></b>"
      when Device::REPORT_TYPE_RUNTIME
        title = "View runtime report"
        uri = "/reports/runtime/#{device.id}"
      when Device::REPORT_TYPE_GPIO1
        title = "View #{device.profile.gpio1_name} report"
        uri = "/reports/gpio1/#{device.id}"
      when Device::REPORT_TYPE_GPIO2
        title = "View #{device.profile.gpio2_name} report"
        uri = "/reports/gpio2/#{device.id}"
    end
    return label unless uri
    %(<a href='#{uri}' title='#{title}'>#{label}</a>)
  end
end

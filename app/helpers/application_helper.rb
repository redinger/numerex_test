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

end

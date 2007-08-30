#!/usr/bin/env ruby

#You might want to change this
ENV["RAILS_ENV"] ||= "development"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true;
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  # Replace this with your code
  ActiveRecord::Base.logger << "This notification daemon is still running at #{Time.now}.\n"
  
  readings_to_notify = Reading.find(:all, :conditions => "event_type like '%geofen%' and notified='0'")
  
  ActiveRecord::Base.logger << "need to notify #{readings_to_notify.size.to_s} users\n"
  
  readings_to_notify.each {|reading| 
                  ActiveRecord::Base.logger << "notify: #{reading.device.account.users[0].email}" }
  
  
  sleep 10
end
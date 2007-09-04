#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "development"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true;
Signal.trap("TERM") do 
  $running = false
end

#while($running) do
  ActiveRecord::Base.logger << "This notification daemon is still running at #{Time.now}.\n"

  readings_to_notify = Reading.find(:all, :conditions => "event_type like '%geofen%' and notified='0'")

  ActiveRecord::Base.logger << "Notification needed for #{readings_to_notify.size.to_s} readings\n"
  
  readings_to_notify.each do |reading| 
    reading.device.account.users.each do |user|
      if user.enotify? 
        ActiveRecord::Base.logger << "notify: #{user.email}\n"
        action = reading.event_type.include?('exit') ? "exited a geofence" : "entered a geofence"
        
        mail = Notifier.create_notify_reading(user, action, reading)
        puts(mail.to_s)
        # would really want to replace previous 2 lines with something like:
        # Notifier.deliver_notify_reading(user, action, reading)
      end
    end
    reading.notified = true
    reading.save
  end
#  sleep 10

#end
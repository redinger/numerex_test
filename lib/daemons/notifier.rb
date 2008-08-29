#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../../config/environment"

$running = true;
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  logger = ActiveRecord::Base.logger
  logger.info("This notification daemon is still running at #{Time.now}.\n")

  Notifier.send_geofence_notifications(logger)
  
  Notifier.send_device_offline_notifications(logger)
  
  Notifier.send_gpio_notifications(logger)
  
  
  sleep 10

end

#!/usr/bin/env ruby

# Grab the RAILS env setting from mongrel_cluster.yml
mongrel_cluster = "/opt/ublip/rails/shared/config/mongrel_cluster.yml"

# If the mongrel_cluster file doesn't exist it will default to production
if File.exist?(mongrel_cluster)
  settings = YAML::load_file(mongrel_cluster)
  ENV['RAILS_ENV'] = settings['environment']
end

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

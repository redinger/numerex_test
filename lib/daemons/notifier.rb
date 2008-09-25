#!/usr/bin/env ruby

# Load EngineYard config
if File.exist?("/data/ublip/shared/config/mongrel_cluster.yml")
  mongrel_cluster = "/data/ublip/shared/config/mongrel_cluster.yml"
# Load Slicehost config
else
  mongrel_cluster = "/opt/ublip/rails/shared/config/mongrel_cluster.yml"
end

# Load the env from mongrel_cluster
settings = YAML::load_file(mongrel_cluster)
ENV['RAILS_ENV'] = settings['environment']

require File.dirname(__FILE__) + "/../../config/environment"

$running = true;
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  logger = ActiveRecord::Base.logger
  logger.auto_flushing = true
  logger.info("This notification daemon is still running at #{Time.now}.\n")

  Notifier.send_geofence_notifications(logger)
  
  Notifier.send_device_offline_notifications(logger)
  
  Notifier.send_gpio_notifications(logger)
  
  Notifier.send_speed_notifications(logger)
  
  sleep 10

end

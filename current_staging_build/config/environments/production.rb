# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
  :domain             => "ublip.com",
  :perform_deliveries => true,
  :address            => 'smtp.ey01.engineyard.com',
  :port               => 25
}

Google_Maps_Api_Key = 'ABQIAAAAb5FIzoTRib2_GSmlbkQ7mBQdy8buJCn4UCOrVn-gOC82x0BwgBQmZoveMS-zQ1aZv3RjGKOBbmDg9Q'
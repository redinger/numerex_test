require File.dirname(__FILE__) + '/../test_helper'

class GroupNotificationTest < Test::Unit::TestCase
  fixtures :group_notifications

  def setup
      @logger = ActiveRecord::Base.logger
      @logger.auto_flushing = true
      @logger.info("This notification daemon is still running at #{Time.now}.\n")    
      NotificationState.instance.begin_reading_bounds
  end
  
    #~ def test_send_geofence_notifications
       #~ readings = Notifier.send_geofence_notifications(@logger)
       #~ assert_equal 0, readings.length
    #~ end

    def test_send_device_offline_notifications
        devices_to_notify = Notifier.send_device_offline_notifications(@logger)
        assert_equal 3,devices_to_notify[0].id
        assert_equal "device 3",devices_to_notify[0].name
    end    
    
    def test_send_gpio_notifications
        devices_to_notify = Notifier.send_gpio_notifications(@logger)
        assert_equal 0,devices_to_notify.length
    end
    
    def test_send_speed_notifications
        devices_to_notify = Notifier.send_speed_notifications(@logger)
        assert_equal 5,devices_to_notify.length
    end    
end

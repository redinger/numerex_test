require File.dirname(__FILE__) + '/../test_helper'


class GeofenceNotificationTest < Test::Unit::TestCase
  
  def record_notification(action,reading)
    @notified_actions.push(action)
  end
  
  context "A geofence notification" do
    setup do
      Reading.delete_all
      #mock out send method for testing
      Notifier.class_eval do
        def Notifier.send_notify_reading_to_users(action,reading)
          @test.record_notification(action,reading)
        end
        def Notifier.set_test(test)
          @test = test
        end
      end
      
      Notifier.set_test(self)
      @notified_actions = Array.new
      @notified_readings = Array.new
    end
    
    teardown do
      #reload notifier to remove mocked method
      Object.class_eval do
        remove_const :Notifier.to_s
        load "notifier.rb"
      end
    end
    
      should "notify on a geofence event" do
        create_reading(@device, 2)
        assert_equal 1, @notified_actions.size
      end
      
    end
    
    
  def create_reading(device, geofence)
    Factory.create(:reading, :device => device, :event_type => "entergeofen#{geofence}")
    NotificationState.instance.begin_reading_bounds
    Notifier.send_geofence_notifications(Logger.new("logger"))
    NotificationState.instance.end_reading_bounds
  end
  
end
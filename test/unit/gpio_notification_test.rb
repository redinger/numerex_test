require File.dirname(__FILE__) + '/../test_helper'

module MockReadingNotifier
  def Notifier.send_notify_reading_to_users(action,reading)
    @test.record_notification(action,reading)
  end
  def set_test(test)
    @test = test
  end
end


class GPIONotificationTest < Test::Unit::TestCase
  
public
def record_notification(action,reading)
  @notified_actions.push(action)
end

  context "A GPIO notification" do
    setup do
      Notifier.extend(MockReadingNotifier)
      Notifier.set_test(self)
      @notified_actions = Array.new
      @notified_readings = Array.new
    end
    
    teardown do
      Object.class_eval do
        remove_const :Notifier.to_s
        load "notifier.rb"
      end
    end
    
    context "with profile watching GPIO1" do
      setup do
        @profile = Factory.create(:device_profile, :watch_gpio1 => true)
        @device = Factory.create(:device, :profile => @profile)
      end
      
      should "notify on GPIO1 L/H" do
        Factory.create(:reading, :device => @device, :gpio1 => false)
        NotificationState.instance.begin_reading_bounds
        Notifier.send_gpio_notifications(Logger.new("logger"))
        NotificationState.instance.end_reading_bounds
        Factory.create(:reading, :device => @device, :gpio1 => true)
        NotificationState.instance.begin_reading_bounds
        Notifier.send_gpio_notifications(Logger.new("logger"))
        NotificationState.instance.end_reading_bounds
        assert_equal 1, @notified_actions.size
        assert @notified_actions.include?(@profile.gpio1_high_notice)
      end
    end
    
    
  end
  
end
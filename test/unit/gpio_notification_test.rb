require File.dirname(__FILE__) + '/../test_helper'


class GPIONotificationTest < Test::Unit::TestCase
  
  def record_notification(action,reading)
    @notified_actions.push(action)
  end
  
  context "A GPIO notification" do
    setup do
      
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
    
    context "with profile watching GPIO1" do
      setup do
        @profile = Factory.create(:device_profile, :watch_gpio1 => true)
        @device = Factory.create(:device, :profile => @profile)
      end
      
      should "notify on GPIO1 L/H" do
        create_reading(@device, false, false)
        create_reading(@device, true, false)
        assert_equal 1, @notified_actions.size
        assert @notified_actions.include?(@profile.gpio1_high_notice)
      end
      
      should "not notify on GPIO2 L/H" do
        create_reading(@device, false, false)
        create_reading(@device, false, true)
        assert_equal 0, @notified_actions.size
      end
    end
    
    context "with a profile watching GPIO2" do
       setup do
        @profile = Factory.create(:device_profile, :watch_gpio2 => true)
        @device = Factory.create(:device, :profile => @profile)
      end
      
      should "notify on GPIO2 L/H" do
        create_reading(@device, false, false)
        create_reading(@device, false, true)
        assert_equal 1, @notified_actions.size
        assert @notified_actions.include?(@profile.gpio1_high_notice)
      end
      
      should "not notify on GPIO1 L/H" do
        create_reading(@device, false, false)
        create_reading(@device, true, false)
        assert_equal 0, @notified_actions.size
      end
    end
  end
  
  def create_reading(device, gpio1, gpio2)
    Factory.create(:reading, :device => device, :gpio1 => gpio1, :gpio2 => gpio2)
    NotificationState.instance.begin_reading_bounds
    Notifier.send_gpio_notifications(Logger.new("logger"))
    NotificationState.instance.end_reading_bounds
  end
  
end
require File.dirname(__FILE__) + '/../test_helper'


class SpeedNotificationTest < Test::Unit::TestCase
  
  def record_notification(action,reading)
    @notified_actions.push(action)
  end
  
  context "A speed notification" do
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
    
    context "with profile that includes speed" do
      setup do
        account = Factory.create(:account, :max_speed => 100)
        @profile = Factory.create(:device_profile, :speeds => true)
        @device = Factory.create(:device, :profile => @profile, :account => account)
      end
      
      should "not notify on non speeding event" do
        create_reading(@device, 99)
        assert_equal 0, @notified_actions.size
      end
      
      should "notify on speeding event" do
        create_reading(@device, 150)
        assert_equal 1, @notified_actions.size
        assert @notified_actions.include?("maximum speed of #{@device.account.max_speed} MPH exceeded")
      end
      
      should "notify again only after a 0 speed" do
        create_reading(@device, 150)
        assert_equal 1, @notified_actions.size
        create_reading(@device, 150)
        assert_equal 1, @notified_actions.size
        create_reading(@device, 0)
        assert_equal 1, @notified_actions.size
        create_reading(@device, 120)
        assert_equal 2, @notified_actions.size
      end
    end
    
    context "with a profile that does not have speeds" do
       setup do
        account = Factory.create(:account, :max_speed => 100)
        @profile = Factory.create(:device_profile, :speeds => false)
        @device = Factory.create(:device, :profile => @profile, :account => account)
      end
      
      should "not notify on a speeding event" do
        create_reading(@device, 150)
        assert_equal 0, @notified_actions.size
      end
    end
  end
  
  def create_reading(device, speed)
    Factory.create(:reading, :device => device, :speed => speed)
    NotificationState.instance.begin_reading_bounds
    Notifier.send_speed_notifications(Logger.new("logger"))
    NotificationState.instance.end_reading_bounds
  end
  
end
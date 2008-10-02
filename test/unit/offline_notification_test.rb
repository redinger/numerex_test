require File.dirname(__FILE__) + '/../test_helper'

module MockOfflineNotifier
  def deliver_device_offline(user, device) 
    puts "delivering #{device.name} to #{user.first_name}"
    @test.record_notification(user,device)
  end
  def set_test(test)
    @test = test
  end
end



class OfflineNotificationTest < Test::Unit::TestCase
  
public
def record_notification(user,device)
  @notifications.push(user)
  @notified_devices.push(device)
end
  
  
  context "A device offline notification" do
    setup do
      @notifications = Array.new
      @notified_devices = Array.new
      Account.delete_all
      User.delete_all
      Device.delete_all
      Group.delete_all
      GroupNotification.delete_all
      Notifier.extend(MockOfflineNotifier)
      Notifier.set_test(self)
    end
    
    teardown do
      Object.class_eval do
        remove_const :Notifier.to_s
        load "notifier.rb"
      end
    end
      
      context "without groups" do
        
        setup do
          @user = Factory.create(:user, :enotify => 1)
          @device = Factory.create(:device, :account => @user.account)
        end
        
        should "be sent for offline device" do
        @device.last_online_time = Time.at(0)
        @device.save
        Notifier.send_device_offline_notifications(Logger.new("logger"))
        assert_equal 1, @notifications.size
        assert @notifications.include?(@user)
      end
      
      should "not be sent for an online device" do
      @device.last_online_time = Time.now
      @device.save
      Notifier.send_device_offline_notifications(Logger.new("logger"))
      assert_equal 0, @notifications.size
    end
    
    should "only be sent every 24 hours" do
      @device.last_online_time = Time.at(0)
      @device.save
      pretend_now_is(Time.local(2000,"jan",1,20,15,1)) do
        Notifier.send_device_offline_notifications(Logger.new("logger"))
        assert_equal 1, @notifications.size
        Notifier.send_device_offline_notifications(Logger.new("logger"))
        assert_equal 1, @notifications.size
      end
      pretend_now_is(Time.local(2000,"jan",2,21,15,1)) do
        Notifier.send_device_offline_notifications(Logger.new("logger"))
        assert_equal 2, @notifications.size
      end
    end
    
  end
  
  context "with groups" do
    setup do
      @user = Factory.create(:user, :enotify => 2)
      group1 = Factory.create(:group, :account => @user.account)
      group2 = Factory.create(:group, :account => @user.account)
      @device1 = Factory.create(:device, :account => @user.account, :group => group1, :last_online_time => Time.at(0))
      @device2 = Factory.create(:device, :account => @user.account, :group => group2, :last_online_time => Time.at(0))
      puts "device 1 in group #{@device1.group.name}"
      puts "device 2 in group #{@device2.group.name}"
      gn = Factory.create(:group_notification, :user => @user, :group => group1)
      Notifier.send_device_offline_notifications(Logger.new("logger"))
    end
    
    should "notify for devices in subscribed group" do
    assert_equal 1, @notifications.size
    assert @notifications.include?(@user)
    assert_equal 1, @notified_devices.size
    assert @notified_devices.include?(@device1)
    assert_equal false, @notified_devices.include?(@device2)
  end
end
end


end
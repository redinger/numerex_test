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

public
def record_notification(user,device)
  @notifications.push(user)
end

class OfflineNotificationTest < Test::Unit::TestCase
  
  context "A device offline notification" do
    setup do
      @notifications = Array.new
      User.delete_all
      Device.delete_all
      Notifier.extend(MockOfflineNotifier)
      Notifier.set_test(self)
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


end
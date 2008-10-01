require File.dirname(__FILE__) + '/../test_helper'


class NotificationTest < Test::Unit::TestCase
  fixtures :notifications, :users, :readings, :devices
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @notified_users = Array.new
    @notified_readings = Array.new
  end
  
  def record_notification(user, reading)
    @notified_users.push(user)
    @notified_readings.push(reading)
  end
  
  # Replace this with your real tests.
  def test_truth
    assert_equal "device_offline", notifications(:one).notification_type.to_s
  end
  
  def test_notify_device_offline
    user = users(:dennis)
    device = devices(:device1)
    response = Notifier.deliver_device_offline(user, device)
    assert_equal 'Device Offline Notification', response.subject
    assert_match /Dear #{user.first_name} #{user.last_name},\n\ndevice 1 seems to be offline/, response.body
  end
  
  def test_notify_forgot_password
    user = users(:dennis)
    response = Notifier.deliver_forgot_password(user, "http://a.com")
    assert_equal 'Forgotten Password Notification', response.subject
    assert_equal user.email, response.destinations[0]
  end
  
  def test_notify_change_password
    user = users(:dennis)
    response = Notifier.deliver_change_password(user, "http://a.com")
    assert_equal 'Changed Password Notification', response.subject
    assert_equal user.email, response.destinations[0]
  end
  
  def test_notify_app_feedback
    user = users(:dennis)
    response = Notifier.deliver_app_feedback(user, "qwerty", "your app rocks!")
    assert_equal 'Feedback from qwerty.ublip.com', response.subject
    assert_equal "support@ublip.com", response.destinations[0]
  end
  
  def test_notify_order_confirmation
    user = users(:dennis)
    response = Notifier.deliver_order_confirmation(42, 42, "order_details", user.email, "password", "qwerty")
    assert_equal 'Thank you for ordering from Ublip', response.subject
    assert_equal user.email, response.destinations[0]
  end
  
  context "A reading notification" do
    setup do
      @user1 = Factory.build(:user, :time_zone => "GMT")
      @user2 = Factory.build(:user, :time_zone => "Pacific Time (US & Canada)")
      @reading = Factory.build(:reading, :created_at => Time.gm(2000,"jan",1,20,15,1))
      @response_user1 = Notifier.deliver_notify_reading(@user1, "did something", @reading)
      @response_user2 = Notifier.deliver_notify_reading(@user2, "did something", @reading)
    end
    should "have the correct content" do
      assert_equal  @response_user1.subject, "#{@reading.device.name} did something"
      assert_equal  [@user1.email], @response_user1.to
      assert_equal ["alerts@ublip.com"], @response_user1.from
      assert_equal "Dear #{@user1.first_name} #{@user1.last_name},\n\nDevice 1 did something at Sat, Jan 01 2000 20:15:01\n", @response_user1.body
      assert_equal "Dear #{@user2.first_name} #{@user2.last_name},\n\nDevice 1 did something at Sat, Jan 01 2000 12:15:01\n", @response_user2.body
    end
  end
  
  context "reading notifications" do
    setup do
      module MockNotify
        def set_test(test)
          @test = test
        end
        
        def deliver_notify_reading(user, action, reading)
          puts "notifying #{user.first_name}"
          @test.record_notification(user, reading)
        end
      end
      Notifier.extend(MockNotify)
      Notifier.set_test(self)
      User.delete_all #must delete since some tests are still using fixtures
    end
    
    context "without groups" do
      setup do
        account = Factory.create :account
        @user1 = Factory.create :user, :account => account, :enotify => 1
        @user2 = Factory.create :user, :account => account, :enotify => 1
        @user3 = Factory.create :user, :account => account, :enotify => 0
        device = Factory.create :device, :account => account
        @reading = Factory.create :reading, :device => device
        Notifier.send_notify_reading_to_users("testing",@reading)
      end
      
      should "notify users with all notifications on" do
        assert_equal 2, @notified_users.size
        assert @notified_users.include?(@user1)
        assert @notified_users.include?(@user2)
      end
      
      should "not notify users with all notifications off" do
        assert_equal false, @notified_users.include?(@user3)
      end
    end
    
    context "with groups" do
      setup do
        @notified_users = Array.new
        @user4 = Factory.create(:user, :enotify => 2)
        group1 = Factory.create :group, :account => @user4.account
        group2 = Factory.create :group, :account => @user4.account
        group3 = Factory.create :group, :account => @user4.account
        gn1 = Factory.create :group_notification, :user => @user4, :group => group1
        gn2 = Factory.create :group_notification, :user => @user4, :group => group2
        device2 = Factory.create(:device, :group => gn1.group, :account => @user4.account)
        device3 = Factory.create(:device, :group => gn2.group, :account => @user4.account)
        device4 = Factory.create(:device, :group => group3, :account => @user4.account)
        @reading1 = Factory.create :reading, :device => device2
        @reading2 = Factory.create :reading, :device => device3
        @reading3 = Factory.create :reading, :device => device4
        Notifier.send_notify_reading_to_users("testing", @reading1)
        Notifier.send_notify_reading_to_users("testing", @reading2)
        Notifier.send_notify_reading_to_users("testing", @reading3)
      end
      
      should "only notify user for subscribed groups" do
      assert_equal 2, @notified_users.size
      assert_equal @user4, @notified_users[0]
      assert_equal @user4, @notified_users[1]
      assert_equal 2, @notified_readings.size
      assert @notified_readings.include?(@reading1)
      assert @notified_readings.include?(@reading2)
      assert_equal false, @notified_readings.include?(@reading3)
    end
  end
  
end
end

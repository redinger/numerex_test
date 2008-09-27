require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  fixtures :groups, :users, :group_notifications

  def setup
    @group = Group.find(1)
  end 
  
  def test_group_create
    group = Group.new
    group.name = nil
    assert !group.save    
    assert_equal 1, group.errors.count
  end  
  
  
  def test_group_edit
    group = Group.find @group.id
    group.name = nil
    assert !group.save
    assert_equal 1, group.errors.count
  end  
  
  def test_group_delete
    group = Group.find @group.id
    assert group.destroy
  end
 
  def test_is_group_notification_true
     assert_equal true,@group.is_selected_for_notification(users(:dennis)) 
  end

  def test_is_group_notification_false
     assert_equal false,@group.is_selected_for_notification(users(:nick)) 
  end

  def test_ordered_devices
      assert_equal 2,@group.ordered_devices.size
  end
  
end

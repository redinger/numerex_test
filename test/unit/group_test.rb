require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  fixtures :groups

  def setup
    @group = Group.find(1)
  end 
  
  def test_group_create
    group = Group.new
    group.name = nil
    assert !group.save
    puts group.errors.full_messages[0]
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
end

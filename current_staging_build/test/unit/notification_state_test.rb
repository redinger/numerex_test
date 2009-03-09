require File.dirname(__FILE__) + '/../test_helper'

class NotificationStateTest < ActiveSupport::TestCase
  fixtures :notification_states, :readings

  def test_precise_ranges
    
    Reading.delete_all #interaction with other test calling NotificationState methods require this
    load_fixtures
    
    all_readings_count = Reading.count(:all)
    
    NotificationState.instance.begin_reading_bounds
    
    Reading.create! # this reading should NOT be included
    
    bound_readings_count = Reading.count(:all,:conditions => NotificationState.instance.reading_bounds_condition)
    
    NotificationState.instance.end_reading_bounds
    
    assert_equal all_readings_count,bound_readings_count # only the initial set should be included
    
    NotificationState.instance.begin_reading_bounds
    
    bound_readings_count = Reading.count(:all,:conditions => NotificationState.instance.reading_bounds_condition)
    
    NotificationState.instance.end_reading_bounds
    
    assert_equal 1,bound_readings_count # only the previously-created reading should be found
    
    begin
      Reading.count(:all,:conditions => NotificationState.instance.reading_bounds_condition)
      fail "Exception expected"
    rescue
      # do nothing, exception expected
    end
  end
  
end

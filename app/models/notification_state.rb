require 'singleton'

class NotificationState < ActiveRecord::Base
  include Singleton
  
  def self.instance
    @@instance ||= (find(:first) or new)
  end
  
  def begin_reading_bounds
    next_reading = Reading.find(:first,:order => "id desc")
    @next_reading_id = next_reading ? next_reading.id : 0
  end
  
  def end_reading_bounds
    raise "Reading bounds not initialized" unless @next_reading_id
    self.last_reading_id = @next_reading_id
    @next_reading_id = nil
    self.save!
  end
  
  def reading_bounds_condition(table_name = Reading.table_name)
    raise "Reading bounds not initialized" unless @next_reading_id
    "#{table_name}.id > #{last_reading_id} and #{table_name}.id <= #{@next_reading_id}"
  end
  
private
  @@instance = nil
end

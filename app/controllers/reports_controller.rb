class ReportsController < ApplicationController
  def index
  end
  
  # Find all readings in descending order, limit 50
  def all_readings
    @readings = Reading.find(:all, :order => "created_at desc", :limit => 50)
  end
  
  def stop
    @readings = Reading.find(:all, :order => "created_at desc", :limit => 50, :conditions => "event_type='stop'")
  end
  
  def start
    @readings = Reading.find(:all, :order => "created_at desc", :limit => 50, :conditions => "event_type='start'")
  end
  
  def speed
    @readings = Reading.find(:all, :order => "created_at desc", :limit => 50, :conditions => "event_type='speed'")
  end

end

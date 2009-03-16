class TripEvent < ActiveRecord::Base
  belongs_to :device
  belongs_to :reading_start,:class_name => "Reading"
  belongs_to :reading_stop,:class_name => "Reading"
  
  def update_stats
    return unless reading_start and reading_stop
    
    self.idle = IdleEvent.sum(:duration,:conditions => ['device_id = ? and created_at between ? and ?',self.device_id,reading_start.created_at,reading_stop.created_at],:order => 'created_at')

    self.distance = 0
    last_latitude,last_longitude = 0,0
    readings = Reading.find(:all,:conditions => ['device_id = ? and created_at between ? and ?',self.device_id,reading_start.created_at,reading_stop.created_at],:order => 'created_at')
    for reading in readings
      next_distance = TripEvent.connection.execute("select distance(latitude,longitude,#{last_latitude},#{last_longitude}) from readings where id = #{reading.id} and latitude != 0 and longitude != 0").fetch_row if reading.latitude != 0 and reading.longitude != 0 and last_latitude != 0 and last_longitude != 0
      self.distance += next_distance[0].to_f if next_distance
      last_latitude,last_longitude = reading.latitude,reading.longitude
    end
    
    save!
  end
end
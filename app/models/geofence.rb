class Geofence < ActiveRecord::Base
  belongs_to :device
  belongs_to :account
  #~ validates_uniqueness_of :fence_num, :scope => :device_id
  #~ validates_presence_of   :fence_num #,:device_id 
  validates_presence_of :name
  
  def find_fence_num
    for i in 1..300
      if(device.get_fence_by_num(i).nil?)
        num = i
        break
      end
    end
    if(num.nil?)
      raise "no fences available"
    else 
      self.fence_num = num
    end
  end
  
  def bounds
    latitude.to_s + "," + longitude.to_s + "," + radius.to_s
  end

  def get_lat_lng      
     if !(self.address =~ /[a-zA-Z]/)
         return "#{self.latitude.round(2)}, #{self.longitude.round(2)}" 
     else
         return self.address
     end    
  end
  
end

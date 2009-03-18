require 'net/http'
require "rexml/document"

class Reading < ActiveRecord::Base
  belongs_to :device
  has_one :stop_event
  include ApplicationHelper
  
  acts_as_mappable  :lat_column_name => :latitude,:lng_column_name => :longitude
  
  def self.generate_direction_string(dir)
    if dir >= 337.5 or dir < 22.5
      return "n"
    elsif dir >= 22.5 and dir < 67.5
      return "ne"
    elsif dir >= 67.5 and dir < 112.5
      return "e"
    elsif dir >= 112.5 and dir < 157.5
      return "se"
    elsif dir >= 157.5 and dir < 202.5
      return "s"
    elsif dir >= 202.5 and dir < 247.5
      return "sw"
    elsif dir >= 247.5 and dir < 292.5
      return "w"
    elsif dir >= 292.5 and dir < 337.5
      return "nw"
    end
  end
  
  def direction_string
    generate_direction_string(direction)
  end
  
  def speed
    spd = read_attribute(:speed)
    if spd.nil?
      "N/A"
    else
      read_attribute(:speed).round
    end
  end
  
  def get_fence_name
    if(!self.event_type.include?("geofen"))
      return nil
    else
      fence_id = self.event_type.split('_')[1]
      return Geofence.exists?(fence_id) ? Geofence.find(fence_id).name : nil
    end
  end
  
  
  def short_address
    if(admin_name1.nil?)
      latitude.to_s + ", " + longitude.to_s
    else
      begin
        addressParts = Array.new
        if(!street.nil?)
          if(!street_number.nil?) 
            streetAddress = [street_number, street]
            streetAddress.delete("")
            addressParts << streetAddress.join(' ')
          else 
            addressParts << street
          end
        end
        addressParts << place_name
        addressParts << admin_name1
        addressString = addressParts.join(', ')
        addressString.empty? ? latitude.to_s + ", " + longitude.to_s : addressString
      rescue
        latitude.to_s + ", " + longitude.to_s
      end
    end
  end
  
end

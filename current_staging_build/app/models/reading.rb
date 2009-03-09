require 'net/http'
require "rexml/document"

class Reading < ActiveRecord::Base
  belongs_to :device
  has_one :stop_event
  include ApplicationHelper
  
  acts_as_mappable  :lat_column_name => :latitude,:lng_column_name => :longitude
  
  
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

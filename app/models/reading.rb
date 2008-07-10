require 'net/http'
require "rexml/document"

class Reading < ActiveRecord::Base
  belongs_to :device
  has_one :stop_event
  
  acts_as_mappable  :lat_column_name => :latitude,
                    :lng_column_name => :longitude
                   
  def speed
    read_attribute(:speed).round
  end
  
  def get_fence_name
    if(!self.event_type.include?("geofen"))
      return nil
    else
       fence_id = self.event_type.split('_')[1]
       return Geofence.exists?(fence_id) ? Geofence.find(fence_id).name : nil
    end
  end


  def shortAddress
    if(address.nil?)
      latitude.to_s + ", " + longitude.to_s
    else
      begin
          doc = REXML::Document.new address
          streetNumber = doc.get_text('/geonames/address/streetNumber').to_s
          street = doc.get_text('/geonames/address/street').to_s
          city = doc.get_text('/geonames/address/placename').to_s 
          state = doc.get_text('/geonames/address/adminName1').to_s
          streetAddress = [streetNumber, street]
          streetAddress.delete("")
          shortAddress = [ streetAddress.join(' '), city, state]
          shortAddress.delete("")
          addressString = shortAddress.join(', ')
          addressString.empty? ? latitude.to_s + ", " + longitude.to_s : addressString
      rescue
        latitude.to_s + ", " + longitude.to_s
      end
    end
  end
  
end

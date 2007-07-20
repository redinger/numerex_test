require 'net/http'
require "rexml/document"

class Reading < ActiveRecord::Base
  belongs_to :device
=begin  
  ReverseGeocodeURL = "http://ws.geonames.org/findNearestAddress"
  def address
      base = ReverseGeocodeURL + "?lat=" + latitude.to_s + "&lng=" + longitude.to_s
   begin
      resp = Net::HTTP.get_response(URI.parse(base))
      data = resp.body
      doc = REXML::Document.new data
      streetNumber = doc.get_text('/geonames/address/streetNumber').to_s
      restOfAddress = doc.get_text('/geonames/address/street').to_s + ", " + doc.get_text('/geonames/address/placename').to_s + ", " + doc.get_text('/geonames/address/adminName1').to_s
    
      if streetNumber==""
        restOfAddress
      else
        streetNumber + " " + restOfAddress
      end
  rescue
      latitude.to_s + ", " + longitude.to_s
  end
  end
=end   
end

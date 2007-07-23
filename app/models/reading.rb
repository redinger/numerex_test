require 'net/http'
require "rexml/document"

class Reading < ActiveRecord::Base
  belongs_to :device

  def shortAddress
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
        shortAddress.join(', ')
    rescue
      latitude.to_s + ", " + longitude.to_s
    end
  end
  
end

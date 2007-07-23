require 'net/http'
require "rexml/document"

class Reading < ActiveRecord::Base
  belongs_to :device

  def shortAddress
    begin
      if address != nil
        doc = REXML::Document.new address
        streetNumber = doc.get_text('/geonames/address/streetNumber').to_s
        restOfAddress = doc.get_text('/geonames/address/street').to_s + ", " + doc.get_text('/geonames/address/placename').to_s + ", " + doc.get_text('/geonames/address/adminName1').to_s
        if(streetNumber.nil? && restOfAddress.nil?)
           return latitude.to_s + ", " + longitude.to_s
        end
        if streetNumber==""
          restOfAddress
        else
          streetNumber + " " + restOfAddress
        end
      else
        latitude.to_s + ", " + longitude.to_s
      end
    rescue
      latitude.to_s + ", " + longitude.to_s
    end
 end
end

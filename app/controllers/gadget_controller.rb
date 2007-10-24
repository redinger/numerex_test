class GadgetController < ApplicationController
  
  layout nil
  
  def all
   @subdomain = request.host.split('.')[0]
 end
 
 def single
   @subdomain = request.host.split('.')[0]
   @title = params[:device_name].nil? ? "Ublip Tracker" : "Current Location of #{params[:device_name]}"
 end
 
end

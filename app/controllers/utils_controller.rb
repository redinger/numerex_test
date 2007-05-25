class UtilsController < ApplicationController
  
  # Retrieves a yahoo map tile reference based on lat/lng
  def yahoo_tile
    if params[:lat] && params[:lng]
      base_url = 'http://local.yahooapis.com/MapsService/V1/mapImage?appid=ublip_location_matters&image_width=150&image_height=100&radius=3&latitude=' + params[:lat] + '&longitude=' + params[:lng]
      resp = Net::HTTP.get_response(URI.parse(base_url))
      doc = REXML::Document.new resp.body
      img = doc.elements[1]
      render :xml => img.to_s
    else
      render_text ''
    end
  end
  
end
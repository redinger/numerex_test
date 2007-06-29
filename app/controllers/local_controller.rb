class LocalController < ApplicationController
layout "local", :except => ["query"]
require 'net/http'
require 'rexml/document'
  def index
  end
  
  def query
    localURL = "http://local.yahooapis.com/LocalSearchService/V2/localSearch?appid=ublip_location_matters&query=#{params[:query]}&zip=#{params[:zip]}&results=#{params[:resultCount]}";
    @xml_data = Net::HTTP.get_response(URI.parse(localURL)).body
  end
end

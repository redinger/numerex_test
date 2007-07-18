class LocalController < ApplicationController
layout "local", :except => ["query"]
require 'net/http'
require 'rexml/document'
  def index
  end
  
  def query
    localURL = "http://local.yahooapis.com/LocalSearchService/V2/localSearch?appid=ublip_location_matters&query=#{CGI.escape(params[:query])}&latitude=#{params[:lat]}&longitude=#{params[:lng]}&results=20";
    puts localURL
    response = Net::HTTP.get_response(URI.parse(localURL)).body
    render_xml response
  end
end

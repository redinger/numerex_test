class GeofenceController < ApplicationController
  before_filter :authorize

  def index
    
  end

  def add
    @device = Device.find(params[:id], :conditions => ["account_id = ?", session[:account_id]])
  end
  
  def view
    @device = Device.find(params[:id], :conditions => ["account_id = ?", session[:account_id]])
  end
end
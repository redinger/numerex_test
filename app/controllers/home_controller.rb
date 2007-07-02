class HomeController < ApplicationController
  before_filter :authorize

  def index
    @devices = Device.get_devices(session[:account_id]) # Get devices associated with account
  end
  
end

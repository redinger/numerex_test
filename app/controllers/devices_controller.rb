class DevicesController < ApplicationController
  #scaffold :device
  
  def index
    @devices = Device.find(:all)
  end
  
  # User chooses a device to add
  # 1 Mobile phone tracker
  # 2 Personal tracker
  # 3 Fleet tracker
  def choose
    if params[:id] == '3'
      
    end
  end
end

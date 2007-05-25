class DevicesController < ApplicationController
  #scaffold :device
  
  # GET /devices /devices.xml
  def index
    @devices = Device.find(:all)
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml {render :xml => @devices.to_xml}
    end
  end
  
  # GET /devices/1 /devices/1.xml
  def show
    @device = Device.find(params[:id])
  
    respond_to do |format|
      format.html # show.rhtml
      format.xml {render :xml => @device.to_xml}
    end
  end
  
  
end

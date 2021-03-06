class Admin::DevicesController < ApplicationController
  before_filter :authorize_super_admin
  layout 'admin'
  
  helper_method :device_imei_or_link
  
  def device_imei_or_link(logical_device)
    gateway = Gateway.find(logical_device.gateway_name)
    return logical_device.imei unless gateway and logical_device.gateway_device
    %(<a href="#{gateway.device_uri}/#{logical_device.gateway_device.id}">#{logical_device.imei}</a>)
  end
  
  def index
    if params[:id]
      @devices = Device.find(:all, :order => "profile_id,name", :conditions => ["account_id = ?", params[:id]])
    else
      @devices = Device.find(:all, :order => "profile_id,name")
    end
    
    @accounts = Account.find(:all, :order => "company")
  end

  def show
    @device = Device.find(params[:id])
  end

  def new
   @device = Device.new
   @accounts = Account.find(:all, :order => "company")
  end

  def edit
    @device = Device.find(params[:id])
    @accounts = Account.find(:all, :order => "company")
  end

  def create
    if request.post?
      device = Device.new(params[:device])
      
      params[:device][:is_public] == '1' ? device.is_public = true : device.is_public = false
  
      if device.save
        redirect_to :action => 'index' and return
        flash[:success] = "#{device.name} created successfully"
      else
        error_msg = ''
        device.errors.each_full do |error|
          error_msg += error + "<br />"
        end
        flash[:error] = error_msg
        redirect_to :action => "new" and return
      end
    end
  end

  def update
    if request.post?
      device = Device.find(params[:id])
      params[:device][:is_public].nil? ? device.is_public = false : device.is_public = true
      device.update_attributes(params[:device])
      flash[:success] = "#{device.name} updated successfully"
    
      if params[:device][:account_id]
         redirect_to :action => 'index', :id => params[:device][:account_id].to_s
       else
         redirect_to :action => 'index'
       end
    end
  end

  def destroy
    if request.post?
      device = Device.find(params[:id])
      device.update_attribute(:provision_status_id, 2)
      device.save!
      flash[:success] = "#{device.name} deleted successfully"
    end  
    redirect_to :action => 'index'
    
  end
  
end

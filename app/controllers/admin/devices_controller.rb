class Admin::DevicesController < ApplicationController
  before_filter :authorize_super_admin
  layout 'admin'
  def index
    if params[:id]
      @devices = Device.find(:all, :order => "name", :conditions => ["account_id = ?", params[:id]])
    else
      @devices = Device.find(:all, :order => "name")
    end
    
    @accounts = Account.find(:all, :order => "company")
  end

  def show
  
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
      device.save
      flash[:message] = "#{device.name} created successfully"
    end
    redirect_to :action => 'index'
  end

  def update
    if request.post?
      device = Device.find(params[:id])
      device.update_attributes(params[:device])
      flash[:message] = "#{device.name} updated successfully"
    end
    redirect_to :action => 'index'
  end

  def destroy
    if request.post?
      device = Device.find(params[:id])
      device.update_attribute(:provision_status_id, 2)
      device.save!
    end  
    redirect_to :action => 'index'
    
  end
  
end
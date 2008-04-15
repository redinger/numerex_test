class Admin::DevicesController < ApplicationController
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
    device = Device.new(params[:device])
    device.save
    flash[:message] = "#{device.name} created successfully"
    redirect_to :action => 'index'
  end

  def update
    device = Device.find(params[:id])
    device.update_attributes(params[:device])
    flash[:message] = "#{device.name} updated successfully"
    redirect_to :action => 'index'
  end

  def destroy
    device = Device.find(params[:id])
    device.update_attribute(:provision_status_id, 0)
    device.save!
    redirect_to :action => 'index'
  end
  
end
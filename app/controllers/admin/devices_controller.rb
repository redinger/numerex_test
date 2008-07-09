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
      device.update_attributes(params[:device])
      flash[:success] = "#{device.name} updated successfully"
    end
    redirect_to :action => 'index'
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

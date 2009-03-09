class HomeController < ApplicationController
  before_filter :authorize
  
  def index    
    @all_groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name', :include=>[:devices])    
    @device_count = Device.count(:all, :conditions => ['provision_status_id = 1 and account_id = ?', session[:account_id]])
    @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name', :include => :profile)                           
    @all_devices=Device.find(:all, :conditions=>['account_id=? and provision_status_id=1',session[:account_id]], :order=>'name', :include => :profile)                           
    assign_the_selected_group_to_session 
  end
  
  def statistics
    @from_statistics  = true
    index 
  end
  
  def maintenance
    @from_maintenance = true 
    index 
  end
  
  def show_devices
    if params[:group_type]
      if (group_id = params[:group_type].to_i) < 0
        session[:group_value] = 'all'
        session[:home_device] = (-group_id).to_s
      else
        session[:group_value] = params[:group_type]
      end
    end
    session[:home_device] = nil unless session[:group_value] == 'all'
    if params[:frm]=='from_statistics'
      @from_statistics  = true        
      redirect_to :action=>'statistics'
    elsif params[:frm]=='from_maintenance'
      @from_maintenance = true     
      redirect_to :action=>'maintenance'
    else    
      redirect_to :action=>'index'
    end
  end
  
  def map
    render :action => "home/map", :layout => "map_only"   
  end
 
end





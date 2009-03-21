class HomeController < ApplicationController
  before_filter :authorize
  
  def index
    user = User.find(session[:user_id])
    if session[:group_value] or user.default_home_selection.nil?
      redirect_to :action=> (user.default_home_action || session[:last_home_action] || 'locations')
    else
      redirect_to :action=> 'show_devices',:group_type => user.default_home_selection
    end
  end
  
  def locations
    @from_locations = true
    setup_home_info
  end
  
  def status
    @from_status = true
    setup_home_info
  end
  
  def statistics
    @from_statistics  = true
    setup_home_info
  end
  
  def maintenance
    @from_maintenance = true 
    setup_home_info
  end
  
  def show_devices
    set_home_selection(params[:group_type])
    if params[:frm]=='from_statistics'
      @from_statistics  = true        
      redirect_to :action=>'statistics'
    elsif params[:frm]=='from_maintenance'
      @from_maintenance = true     
      redirect_to :action=>'maintenance'
    elsif params[:frm]=='from_locations'
      @from_locations = true     
      redirect_to :action=>'locations'
    elsif params[:frm]=='from_status'
      @from_status = true     
      redirect_to :action=>'status'
    else    
      redirect_to :action=>'index'
    end
  end
  
  def map
    render :action => "home/map", :layout => "map_only"   
  end
  
private
  def setup_home_info
    session[:last_home_action] = params[:action]
    @device_count = Device.count(:all, :conditions => ['provision_status_id = 1 and account_id = ?', session[:account_id]])
    assign_the_selected_group_to_session 
  end
 
end





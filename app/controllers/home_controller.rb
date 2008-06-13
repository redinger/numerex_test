class HomeController < ApplicationController
  before_filter :authorize

  def index
        @devices = Device.get_devices(session[:account_id]) # Get devices associated with account    
        @all_groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]])
        @groups = @all_groups
        @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]])            
        session[:gmap_value] = "all"
  end
  
  def show_devices     
    @all_groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]])
    if params[:type] == "all"
         @groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]])
         @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]])    
     else
         @groups=Group.find(:all, :conditions=>['id=?',params[:type]])
         session[:gmap_value] = params[:type]
         @default_devices=[]    
     end        
    render :layout=>false    
  end
  
  def map
    render :action => "home/map", :layout => "map_only"   
  end
 
end

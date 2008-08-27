class HomeController < ApplicationController
  before_filter :authorize
  
  def index    
      @all_groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
      @devices = Device.get_devices(session[:account_id]) # Get devices associated with account            
     if session[:gmap_value] == "all" || session[:gmap_value].nil?        
        @groups = @all_groups
         session[:gmap_value] = "all"
        @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')            
     elsif session[:gmap_value] == 'default'
         @groups = []
         @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                     
     else
         @groups=Group.find(:all, :conditions=>['id=?',session[:gmap_value]], :order=>'name')                  
         @default_devices=[]            
     end            
  end
  
  def statistics
    index # TODO add proper query
  end
  
  def maintenance
    index # TODO add proper query
  end
  
  def show_devices         
    @all_groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
    if params[:type] == "all"
         session[:gmap_value] = "all"
         @groups= @all_groups 
         @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')    
    elsif params[:type] == "default"
         session[:gmap_value] = params[:type]
         @groups = []
         @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')            
    else
         @groups=Group.find(:all, :conditions=>['id=?',params[:type]], :order=>'name')
         session[:gmap_value] = params[:type]
         @default_devices=[]    
     end
       render :layout=>false    
  end
  
  def map
    render :action => "home/map", :layout => "map_only"   
  end
 
end

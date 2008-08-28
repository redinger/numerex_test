class HomeController < ApplicationController
  before_filter :authorize
  
  def index    
      @all_groups=Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name')
      @devices = Device.get_devices(session[:account_id]) # Get devices associated with account            
      @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')                     
     if session[:gmap_value] == "all" || session[:gmap_value].nil?        
         @groups = @all_groups
         session[:gmap_value] = "all"
         @show_default_devices = true
     elsif session[:gmap_value] == 'default'
         @groups = []  
         @show_default_devices = true
     else
         @groups=Group.find(:all, :conditions=>['id=?',session[:gmap_value]], :order=>'name')                               
         @show_default_devices = false
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
    @devices = Device.get_devices(session[:account_id]) # Get devices associated with account            
    @default_devices=Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name')    
    if params[:type] == "all"
         session[:gmap_value] = "all"
         @groups= @all_groups          
         @show_default_devices = true
    elsif params[:type] == "default"
         session[:gmap_value] = params[:type]
         @groups = []
         @show_default_devices = true
    else
         @groups=Group.find(:all, :conditions=>['id=?',params[:type]], :order=>'name')
         session[:gmap_value] = params[:type]         
         @show_default_devices = false
     end       
     render :action=>'index'
  end
  
  def map
    render :action => "home/map", :layout => "map_only"   
  end
 
end

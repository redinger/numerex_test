class GeofenceController < ApplicationController
  before_filter :authorize

  def index
    device_ids = Device.get_devices(session[:account_id]).map{|x| x.id}        
    if device_ids.empty?       
      @geofences_pages,@geofences = paginate :geofences,:conditions => ["account_id = ?",session[:account_id]], :order => "name",:per_page => 3  
    else
      @geofences_pages,@geofences = paginate :geofences,:conditions => ["device_id in (#{device_ids.join(',')}) or account_id = ?",session[:account_id]], :order => "name",:per_page => 3  
    end    
  end
  
  def new 
    @devices = Device.get_devices(session[:account_id])    
    if request.post?
      geofence = Geofence.new
      add_and_edit(geofence)
      if geofence.save
        flash[:message] = 'Geofence created succesfully'
        redirect_to geofence_url
      else
        flash[:message] = 'Geofence not created'
      end
    end
  end

  def detail
    @account = Account.find_by_id(session[:account_id])
    @geofence = Geofence.find(:first,:conditions => ["id = ?",params[:id]])
  end  
  
  def edit 
    @devices = Device.get_devices(session[:account_id])
    @geofence = Geofence.find(params[:id])     
    if check_action_for_user
      if request.post?           
       add_and_edit(@geofence)
       if @geofence.save
          flash[:message] = 'Geofence updated succesfully'
         redirect_to geofence_url
       else
         flash[:message] = 'Geofence not updated'
       end
      end  
     else
         redirect_to geofence_url
        flash[:message] = 'Invalid action.'
     end    
  end  
  
  def view  
    if (params[:id] =~ /account/)
      id = params[:id].gsub(/account/, '')
      @account = Account.find_by_id(id)
      if params[:gf]
        @gf = Geofence.find(:first,:conditions => ["id = ?",params[:gf]])
      else
        @gf = Geofence.find(:first,:conditions => ["account_id = ?",id])
      end
      @geofences_pages, @geofences = paginate :geofences, :conditions=> ["account_id=?", id], :order => "name",:per_page => 15      
    else
      id = params[:id].gsub(/device/, '')
      @account = Account.find_by_id(session[:account_id])
      @device = Device.find_by_id(id)
      if params[:gf]
        @gf = Geofence.find(:first,:conditions => ["id = ?",params[:gf]])
      else
        @gf = Geofence.find(:first,:conditions => ["device_id = ?",id])
      end
      @geofences_pages, @geofences = paginate :geofences, :conditions=> ["device_id=?", id], :order => "name",:per_page => 15
    end
    @gf_ids = @geofences.map{|x| x.id}
  end
  
  def view_detail 
    geofence = Geofence.find(:first,:conditions => ["id = ?",params[:id]])
    render :update do |page|
      page.replace_html "detail_id#{geofence.id}",:partial => "geofence/detail",:locals => {:geofence => geofence}
      page.show "detail_id#{geofence.id}"
    end
  end  
  
  def delete 
     @geofence=Geofence.find_by_id(params[:id]) 
     if check_action_for_user 
        Geofence.delete(params[:id])
        flash[:message] = 'Geofence deleted successfully'
     else
        flash[:message] = 'Invalid action.'   
     end    
     redirect_to geofence_url
  end  

private
  
  def add_and_edit(geofence) 
    add=params[:address].split(',')
    geofence.latitude , geofence.longitude = add[0] , add[1]
    geofence.name = params[:name]
    geofence.radius = params[:radius]
    geofence.address = params[:address]
    geofence.account_id = params[:radio] == "1" ? session[:account_id] : 0
    geofence.device_id = params[:radio] == "2" ? params[:device]  : 0
  end  
  
end

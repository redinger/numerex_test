class GeofenceController < ApplicationController
  before_filter :authorize

  def index
    device_ids = Device.get_devices(session[:account_id]).map{|x| x.id}
    @geofences_pages,@geofences = paginate :geofences,:conditions => ["device_id in (#{device_ids.join(',')}) or account_id = ?",session[:account_id]], :order => "name",:per_page => 3
  end
  
  # Adding new method for adding geofences for a device =========@better
  def new
    @devices = Device.get_devices(session[:account_id])
    if request.post?
      geofence = Geofence.new
      add_and_edit(geofence)
      if geofence.save
        flash[:message] = 'Geofence created succesfully'
        redirect_to :controller => 'geofence', :action => 'index'
      else
        flash[:message] = 'Geofence not created'
      end
    end
  end

  def detail
    @geofence = Geofence.find(:first,:conditions => ["id = ?",params[:id]])
  end  
  
  def edit # Added new edit method ===========@better
    @devices = Device.get_devices(session[:account_id])
    @geofence = Geofence.find(params[:id])
    if request.post?
      geofence = Geofence.find(params[:id])
      add_and_edit(geofence)
      if geofence.save
        flash[:message] = 'Geofence updated succesfully'
        redirect_to :controller => 'geofence', :action => 'index'
      else
        flash[:message] = 'Geofence not updated'
      end
    end  
  end  
  
  def view   # Added new view method ===========@better
    
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
  
  def view_detail #Added for updating partial on view page =========@better
    geofence = Geofence.find(:first,:conditions => ["id = ?",params[:id]])
    render :update do |page|
      page.replace_html "detail_id#{geofence.id}",:partial => "geofence/detail",:locals => {:geofence => geofence}
      page.show "detail_id#{geofence.id}"
    end
  end  
  
  def delete #New delete method ===========@better
    Geofence.delete(params[:id])
    flash[:message] = 'Geofence deleted successfully'
    redirect_to :action => "index"
  end  

private
  
  def add_and_edit(geofence) #Method used for adding or editing the geofence. =========@better
    add = params[:address].split(',')
    lat = add[0]
    lng = add[1]
    geofence.name = params[:name]
    geofence.latitude= lat
    geofence.longitude = lng
    geofence.radius = params[:radius]
    geofence.address = params[:address]
    geofence.account_id = params[:radio] == "1" ? session[:account_id] : 0
    geofence.device_id = params[:radio] == "2" ? params[:device]  : 0
  end  
  
end

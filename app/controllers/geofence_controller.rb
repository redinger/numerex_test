class GeofenceController < ApplicationController

  before_filter :authorize
  
  def index
    device_ids = Device.get_devices(session[:account_id]).map{|x| x.id}
    if device_ids.empty?       
      @geofences_pages,@geofences = paginate :geofences,
                                             :conditions => ["account_id = ?",session[:account_id]],
                                             :order => "name", :per_page => 25
    else
      @geofences_pages,@geofences = paginate :geofences,
                                             :conditions => ["device_id in (#{device_ids.join(',')}) or account_id = ?",session[:account_id]], 
                                             :order => "name", :per_page => 25
    end
  end
  
  def new 
    @devices = Device.get_devices(session[:account_id])    
    if request.post?
      geofence = Geofence.new
      add_and_edit(geofence)
      if geofence.save
        flash[:success] = "#{geofence.name} created succesfully"
        redirect_to geofence_url
      else
        flash[:error] = 'Geofence not created'
      end
    end
  end

  def detail
    @account = Account.find_by_id(session[:account_id])
    @geofence = Geofence.find(:first,:include => "device",
                  :conditions => ["geofences.id = ? and (devices.account_id = ? or geofences.account_id = ?)",
                                  params[:id],session[:account_id],session[:account_id]])
    if @geofence.nil?
        flash[:error] = "Invalid action."
        redirect_to geofence_url
    end
  end  
  
  def edit 
    @devices = Device.get_devices(session[:account_id])    
 
    @geofence = Geofence.find(:first,:include => "device",
                  :conditions => ["geofences.id = ? and (devices.account_id = ? or geofences.account_id = ?)",
                                  params[:id],session[:account_id],session[:account_id]])
    if @geofence.nil?
       flash[:error] = "Invalid action." 
       redirect_to geofence_url 
       return
    end    
    if check_action_for_user
      if request.post?           
       add_and_edit(@geofence)
       if @geofence.save
          flash[:success] = "#{@geofence.name} updated succesfully"
         redirect_to params[:ref_url]
       else
         flash[:error] = "#{@geofence.name} not updated"
       end
      end  
     else
        flash[:error] = 'Invalid action.'
        redirect_to params[:ref_url]       
     end    
  end  
  
  def view
    per_page = 15
    session[:id] = params[:id] if params[:id]
    if (session[:id] =~ /account/)
      id = session[:id].gsub(/account/, '')
      @account = Account.find_by_id(id)
      if params[:gf]
        goto_correct_page("account",id,per_page)
        @gf = Geofence.find(:first,:conditions => ["id = ?",params[:gf]])
      else
        @geofences_pages, @geofences = paginate :geofences, 
                                                :conditions=> ["account_id=?", id],
                                                :order => "name",:per_page => per_page
        @gf = @geofences.first
      end

    else
      @account = Account.find_by_id(session[:account_id])
      id = session[:id].gsub(/device/, '')
      @device = Device.find_by_id(id)
      if params[:gf]
        goto_correct_page("device",id,per_page)
        @gf = Geofence.find(:first,:conditions => ["id = ?",params[:gf]])
      else
        @geofences_pages, @geofences = paginate :geofences, 
                                                :conditions=> ["device_id=?", id], 
                                                :order => "name",:per_page => per_page
        @gf = @geofences.first
      end      

    end
    @gf_ids = @geofences.map{|x| x.id} if !@geofences.nil?
  end
  
  def view_detail 
    geofence = Geofence.find(:first,:include => "device",
                  :conditions => ["geofences.id = ? and (devices.account_id = ? or geofences.account_id = ?)",
                                  params[:id],session[:account_id],session[:account_id]])

    if geofence.nil?
       flash[:error] = "Invalid action." 
       redirect_to geofence_url 
       return
    end
    render :update do |page|
      page.replace_html "detail_id#{geofence.id}",:partial => "geofence/detail",:locals => {:geofence => geofence}
      page.show "detail_id#{geofence.id}"
    end
  end  
  
  def delete 
    @geofence = Geofence.find(:first,:include => "device",
                  :conditions => ["geofences.id = ? and (devices.account_id = ? or geofences.account_id = ?)",
                                  params[:id],session[:account_id],session[:account_id]])
    
    if @geofence && check_action_for_user 
        Geofence.delete(params[:id])
        flash[:success] = "#{@geofence.name} deleted successfully"
    else
        flash[:error] = 'Invalid action.'   
    end    
    redirect_to geofence_url
  end  

private
  
  def goto_correct_page(a_or_d,id,per_page)
    found = false
    page = 1
    while !found
      params[:page] = page.to_s 
      @geofences_pages, @geofences = paginate :geofences, 
                                              :conditions=> ["#{a_or_d}_id=?", id], 
                                              :order => "name",:per_page => per_page 
      @geofences.each{|g| (found = true; break) if g.id == params[:gf].to_i }

      page += 1 unless found
    end
    page
  end
  
  def add_and_edit(geofence) 
    fence = params[:bounds].split(",")
    geofence.latitude, geofence.longitude, geofence.radius = fence[0], fence[1], fence[2]       
    geofence.name = params[:name]       
    geofence.address = params[:address]
    geofence.account_id = params[:radio] == "1" ? session[:account_id] : 0
    geofence.device_id = params[:radio] == "2" ? params[:device]  : 0
  end  
  
end

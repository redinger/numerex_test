ResultCount =25# Number of results per page
Per_page = 15

class GeofenceController < ApplicationController

  before_filter :authorize

  def index
    device_ids = Device.get_devices(session[:account_id]).map{|x| x.id}
    if device_ids.empty?       
      @geofences = Geofence.paginate(:per_page=>ResultCount, :page=>params[:page],
                                 :conditions => ["account_id = ?",session[:account_id]],
                                 :order => "name")                                 
    else
      @geofences = Geofence.paginate(:per_page=>ResultCount, :page=>params[:page],
                                 :conditions => ["device_id in (#{device_ids.join(',')}) or account_id = ?",session[:account_id]], 
                                 :order => "name")                                             
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
    @geofence = Geofence.find(:first,:include => "device", :conditions => ["geofences.id = ? and ((devices.account_id = ? and devices.provision_status_id =1) or geofences.account_id = ?)", params[:id],session[:account_id],session[:account_id]])
    if @geofence.nil?
      flash[:error] = "Invalid action."
      redirect_to geofence_url
    end
  end

  def edit
    @devices = Device.get_devices(session[:account_id])
    @geofence = Geofence.find(:first,:include => "device", :conditions => ["geofences.id = ? and ((devices.account_id = ? and devices.provision_status_id =1) or geofences.account_id = ?)", params[:id],session[:account_id],session[:account_id]])
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
    session[:id] = params[:id] if params[:id]
    if (session[:id] =~ /account/)
      id = session[:id].gsub(/account/, '')
      @account = Account.find_by_id(id)
      @geofence = Geofence.find(:first, :conditions=>["id=?",params[:gf]])
      if !@geofence.nil? && session[:account_id].to_i == id.to_i
        if params[:gf]
          goto_correct_page("account",id)
          @gf = @geofences.first #Geofence.find(:first,:conditions => ["id = ?",params[:gf]])
        else
          @geofences = Geofence.paginate(:per_page=>Per_page, :page=>params[:page], :conditions=> ["account_id=?", id], :order => "name")
          @gf = @geofences.first
        end
      else
        show_error_message
      end
    else
      @account = Account.find_by_id(session[:account_id])
      id = session[:id].gsub(/device/, '')
      @device = Device.find_by_id(id.to_i, :conditions=>['account_id = ? and provision_status_id = 1',session[:account_id]])

      if !params[:gf] # this will take care of the request coming from devices page with only device id
        if !@device.nil?
          @geofences = Geofence.paginate(:per_page=>Per_page, :page=>params[:page], :conditions=> ["device_id=?", id.to_i], :order => "name")
          @gf = @geofences.first
        else
          flash[:error] = "Invalid action."
          redirect_to :controller =>'devices'
        end
      else # this will take care of request from geofences page
        @geofence = Geofence.find(:first, :conditions=>["id=? and device_id=?",params[:gf], id])
        if !@geofence.nil? && session[:account_id].to_i == @geofence.device.account_id.to_i
          if params[:gf]
            goto_correct_page("device",id.to_i)
            @gf = @geofences.first  #= Geofence.find(:first,:conditions => ["id = ?",params[:gf]])
          end
        else
          show_error_message
        end
      end
    end
    @gf_ids = @geofences.map{|x| x.id} if !@geofences.nil?
  end

  def view_detail
    geofence = Geofence.find(:first,:include => "device", :conditions => ["geofences.id = ? and ((devices.account_id = ? and devices.provision_status_id =1) or geofences.account_id = ?)", params[:id],session[:account_id],session[:account_id]])
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
    @geofence = Geofence.find(:first,:include => "device", :conditions => ["geofences.id = ? and ((devices.account_id = ? and devices.provision_status_id =1) or geofences.account_id = ?)", params[:id],session[:account_id],session[:account_id]])
    if @geofence && check_action_for_user
      Geofence.delete(params[:id])
      flash[:success] = "#{@geofence.name} deleted successfully"
    else
      flash[:error] = 'Invalid action.'
    end
    redirect_to geofence_url
  end

  private

  def show_error_message
    flash[:error] = "Invalid action"
    redirect_to geofence_url
  end

  def goto_correct_page(a_or_d,id)
    page = 1     if !params[:page]
    page=params[:page] #= page.to_s
    @geofences = Geofence.paginate(:per_page=>Per_page, :page=>params[:page], :conditions=> ["#{a_or_d}_id=?", id], :order => "name")
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

class ReadingsController < ApplicationController
  before_filter :authorize_http, :only => ['last', 'all']
  before_filter :authorize, :except => ['last', 'all', 'public'] # Public readings don't require any auth
  
 def show_group_by_id
        @group_for_data=Group.find(:all ,:conditions=>["account_id =?" ,session[:account_id]] )
        group_id = []
        count = 0
        for group in @group_for_data
            group_id[count] = group.id
            count = count + 1
        end
        @devices_ids=GroupDevice.find(:all  , :conditions => ['group_id in (?)', group_id])
        group_id = []
        count = 0
        for group in @devices_ids
            group_id[count] = group.device_id
            count = count + 1
        end
        @group_device_ids=GroupDevice.find(:all  ,  :select => 'distinct(device_id)',:conditions => ['device_id in (?)', group_id])
        group_id = []
        count = 0
        for group in @group_device_ids
            group_id[count] = group.device_id
            count = count + 1
        end
        @devices=Device.find(:all , :conditions => [ ' id in (?) AND account_id=?', group_id ,session[:account_id]] )
        if @group_device_ids== nil ||@group_device_ids.length == 0 
           @devices_all = Device.find(:all, :conditions => ["account_id = ?", session[:account_id]])
        else
           @devices_all =Device.find(:all ,:conditions => [ 'account_id = ? AND id not in (?) ',session[:account_id],group_id])
        end
        @all_devices = Device.find(:all, :conditions => ["account_id = ?", session[:account_id]])
         @count_devices = Device.count(:all, :conditions => ["account_id = ?", session[:account_id]])
        end 
   
  def recent
          @user_pre= params[:id]        
          if   @group_for_data=Group.find(:first,:conditions => ["id=? ", @user_pre])
                #~ @devices_ids=GroupDevice.find(:all  , :conditions => ['group_id =?', @group_for_data.id])
                #~ group_id = []
                #~ count = 0
                #~ for group in @devices_ids
                    #~ group_id[count] = group.device_id
                    #~ count = count + 1
               #~ end  
             @devices=Device.find(:all , :conditions => [ 'group_id=?', params[:id]] )                
         else            
            ( @user_pre == "undefined" || @user_pre == "all"  )         
               @devices = Device.get_devices(session[:account_id])                
         end
    
        render :layout => false
  end
  
  # Display last reading for device
  def last
    account = Account.find(:first, :conditions => ["subdomain = ?", request.host.split('.')[0]])
    device = Device.find(params[:id])
    if(device.account_id == account.id)
      @locations = Reading.find(:all, :conditions => ["device_id = ?", params[:id]], :limit => 1, :order => "created_at desc")
      @device_name = device.name
    else
      @locations = Array.new
    end
    render :layout => false
  end
  
  # Display last reading for all devices under account
  def all
    account_id = Account.find_by_subdomain(request.host.split('.')[0]).id
    @devices = Device.get_devices(account_id)
    render :layout => false
  end
  
  # New action to allow public feeds for devices
  def public
    account_id = Account.find_by_subdomain(request.host.split('.')[0]).id
    @devices = Device.get_public_devices(account_id)
    render :layout => false
  end
  
  # Simple test for iGoogle integration
  def recent_public
    @readings = Reading.find(:all, :conditions => ["device_id = ?", params[:id]], :limit => 1, :order => "created_at desc")
    render_xml reading.to_xml
  end
end

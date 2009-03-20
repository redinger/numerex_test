# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  
  session :session_key => '_ublip_session_id'
  
  before_filter :set_page_title
  before_filter :create_referral_url
  before_filter :set_time_zone
  
  helper_method :all_groups,:all_devices,:current_account,:default_devices
  
  def all_groups
    @all_groups ||= Group.find(:all, :conditions=>['account_id=?',session[:account_id]], :order=>'name', :include=>[:devices])    
  end
  
  def all_devices
    @all_devices ||= Device.find(:all, :conditions=>['account_id=? and provision_status_id=1',session[:account_id]], :order=>'name', :include => :profile)                           
  end
  
  def current_account
    @current_account ||= Account.find(session[:account_id])
  end
  
  def default_devices
    @default_devices ||= Device.find(:all, :conditions=>['account_id=? and group_id is NULL and provision_status_id=1',session[:account_id]], :order=>'name', :include => :profile)                           
  end
  
  # NOTE this might be a nice mixin to be applied to ActiveRecord to complement #update_attribute
  def update_attribute_by_checkbox(model,attribute_name,checkbox_values)
    model.update_attribute(attribute_name,checkbox_values[attribute_name] == "on")
  end
  
  # NOTE this might be a nice mixin to be applied to ActiveRecord to complement #update_attributes
  def update_attributes_with_checkboxes(model,attribute_names,checkbox_values)
    checkbox_values ||= {}
    attribute_names.each do | single_attribute_name |
      update_attribute_by_checkbox(model,single_attribute_name,checkbox_values)
    end
  end
  
  def set_time_zone
    user = User.find_by_id(session[:user_id])
    if !user.nil? && user.time_zone
      Time.zone = user.time_zone 
    else
      Time.zone = 'Central Time (US & Canada)'  
    end    
  end

  def create_referral_url
    unless request.env["HTTP_REFERER"].blank?
      unless request.env["HTTP_REFERER"][/register|login|logout|authenticate/]
        session[:referral_url] = request.env["HTTP_REFERER"]
      end
    end
  end  

  def paginate_collection(options = {}, &block)
    if block_given?
      options[:collection] = block.call
    elsif !options.include?(:collection)
      raise ArgumentError, 'You must pass a collection in the options or using a block'
    end
    default_options = {:per_page => 20 , :page => 1}
    options = default_options.merge options
    pages = Paginator.new self, options[:collection].size, options[:per_page], options[:page]
    first = pages.current.offset
    last = [first + options[:per_page], options[:collection].size].min
    slice = options[:collection][first...last]
    return [pages, slice]
  end

  def date_helpers
    Helper.instance
  end

  def check_action_for_user
    if !@geofence.nil? && (session[:account_id] == @geofence.account_id || (@geofence.device_id !=0 && @geofence.device.account_id == session[:account_id].to_i))
      true
    else
      false
    end           
  end
  
  def set_home_selection(selection)
    if selection.nil?
      session[:group_value] = 'all'
      session[:home_device] = nil
    elsif (group_id = selection.to_i) < 0
      session[:group_value] = 'all'
      session[:home_device] = (-group_id).to_s
    else
      session[:group_value] = selection
      session[:home_device] = nil
    end
  end

  def assign_the_selected_group_to_session
    set_home_selection(nil)  if session[:group_value].nil?
    if session[:group_value]=="all"
      if session[:home_device]
        @groups= []
        @show_default_devices = false
      else
        @groups = all_groups          
        @show_default_devices = true
      end
    elsif session[:group_value]=="default"             
      @groups = []
      @show_default_devices = true
    else
      @groups=Group.find(:all, :conditions=>['id=?',session[:group_value]], :order=>'name', :include=>[:devices])            
      @show_default_devices = false
    end                    
  end    

private

  def authorize
    unless session[:user]
      flash[:message] = "You're not currently logged in"
      if(request.parameters["action"]=="map")
        @session[:return_to] = request.request_uri
        redirect_to :controller => "login", :action => "login_small"
      else
        redirect_to :controller => "login"
      end
    end
  end
  
  # Super admin's globally administer accounts, users, and devices
  def authorize_super_admin
    unless session[:is_super_admin]
      redirect_to :controller => "home"
    end
  end
  
  def authorize_device
    device = Device.find_by_id(params[:id])
    unless device && device.account_id == session[:account_id]
      redirect_back_or_default "/index"
    end
  end
  
  def authorize_user
    user = User.find(params[:id])
    unless user.account_id == session[:account_id]
      redirect_back_or_default "/index"
    end
  end
  
  def authorize_http
    if session[:account_id].nil?
      username, passwd = get_auth_data    
      unless User.authenticate(request.subdomains.first, username, passwd) then access_denied end    
    else
      unless  session[:account_id] then access_denied end      
    end
  end
    
  def access_denied
    headers["Status"]           = "Unauthorized"
    headers["WWW-Authenticate"] = %(Basic realm="Web Password")
    render :text => "Couldn't authenticate you", :status => '401 Unauthorized'
    false
  end  
    
  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end
  
  @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
  
  # gets BASIC auth info
  def get_auth_data
    auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
    auth_data = request.env[auth_key].to_s.split unless auth_key.blank?    
    return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
  end
    
  def set_page_title
    @page_title = "GoTrack"
  end
end

class Helper
  include Singleton
  include ActionView::Helpers::DateHelper
end

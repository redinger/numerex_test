# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  session :session_key => '_ublip_session_id'
  before_filter :set_page_title
  before_filter :create_referral_url     
  
 # from pg. 464 of AWDWR, 1st Ed.
    def rescue_action_in_public(exception)
      if exception.is_a? ActiveRecord::RecordNotFound or exception.is_a? ::ActionController::UnknownAction
        render(:file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found")
      elsif exception.is_a? ::ActionController::RoutingError
        render(:file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found")
      else
        render(:file => "#{RAILS_ROOT}/public/500.html", :status => "500 Server Error")
        SystemNotifier.deliver_exception_notification(self, request, exception)
      end
    end
    
   # capturing local errors due to ssh tunneling, mongrel proxying
    def rescue_action_locally(exception)
      #if running in production capture local and remote errors the same
      if RAILS_ENV == 'production'# or RAILS_ENV == 'development'
        rescue_action_in_public(exception)
      else
        super # call super implementation
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
      username, passwd = get_auth_data
      unless User.authenticate(request.subdomains.first, username, passwd) then access_denied end
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
  
  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end
    
    def set_page_title
      @page_title = "Ublip - Location Matters"
    end
end

class Helper
    include Singleton
    include ActionView::Helpers::DateHelper
end

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'

  session :session_key => '_ublip_session_id'
   
  
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
    device = Device.find(params[:id])
    unless device.account_id == session[:account_id]
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
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
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
end

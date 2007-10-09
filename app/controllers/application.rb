# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'

  session :session_key => '_ublip_session_id'
   
  
  private
  def authorize
    puts request.parameters["action"]
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
  
  def authorize_admin
    #puts "user req auth: " + session[:user].id.to_s + session[:user].to_s
    unless (session[:user] && session[:user]==1)
      flash[:message] = "You're not authorized to view this page"
      raise "not authorized"
    end
  end
end

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_ublip_session_id'
  
  private
  def authorize
    unless session[:user]
      flash[:message] = "You're not currently logged in"
      redirect_to :controller => "login"
    end
  end
end

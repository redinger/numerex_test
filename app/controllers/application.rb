# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_ublip_session_id'
  before_filter :login_from_cookie
   def login_from_cookie
      return unless cookies[:auth_token] && @session[:user].nil?
      user = User.find_by_remember_token(cookies[:auth_token]) 
      if user && !user.remember_token_expires_at.nil? && Time.now < user.remember_token_expires_at 
         @session[:user] = user
      end
   end
  private
  def authorize
    unless session[:user]
      flash[:message] = "You're not currently logged in"
      redirect_to :controller => "login"
    end
  end
end

class LoginController < ApplicationController

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  def index
    # Handles the login form post
    if request.post?
      # Authenticate based on un/pw as well as subdomain
      self.current_user = User.authenticate(request.subdomains.first, params[:email], params[:password])
      if logged_in?
        if params[:remember_me] == "1"
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        session[:account_id] = self.current_user.account_id # Store the account id
        redirect_back_or_default(:controller => '/home', :action => 'index') # Login success
      # Send them back to the login page with appropriate error message
      else
        flash[:message] = 'Please specify a valid username and password.'
        flash[:username] = params[:email]
        redirect_to '/login'
      end
    # Display the appropriate login form based on subdomain
    else
      @account = Account.find_by_subdomain(request.subdomains.first)
      
      # Subdomain does not exist so display appropriate form
      if !@account
        render_text 'this subdomain does not exist, click here to create your account'        
      end
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/login', :action => 'index')
  end
end

class LoginController < ApplicationController

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  def index

    #Check if user is logged in and redirect to home controller if they are
    if logged_in? 
      user = self.current_user
      if !user.remember_token_expires_at.nil? and Time.now < user.remember_token_expires_at 
          redirect_to :controller => 'home' and return
      else
         cookies.delete :auth_token
         self.current_user.forget_me
         reset_session     
      end    
    end
    
    # Handles the login form post
    if request.post?
      # Authenticate based on un/pw as well as subdomain
      if self.current_user = User.authenticate(request.subdomains.first, params[:email], params[:password])
        if params[:remember_me] == "on"
          self.current_user.remember_me
          cookies['auth_token'] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
          cookies['user_name'] = params[:email]
        end
        session[:user_id] = self.current_user.id # Store current user's id
        session[:account_id] = self.current_user.account_id # Store the account id
        session[:company] = self.current_user.account.company # Store the user's company name
        session[:first_name] = self.current_user.first_name # Store user's first name
        redirect_back_or_default(:controller => '/home', :action => 'index') # Login success
      # Send them back to the login page with appropriate error message
      else
        if session[:user_id]
          if self.current_user = User.authenticate_crypt(request.subdomains.first, params[:email], params[:password])
            if params[:remember_me] == "on"
              self.current_user.remember_me
              cookies['auth_token'] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
            end
            session[:user_id] = self.current_user.id # Store current user's id
            session[:account_id] = self.current_user.account_id # Store the account id
            session[:company] = self.current_user.account.company # Store the user's company name
            session[:first_name] = self.current_user.first_name # Store user's first name
            redirect_back_or_default(:controller => '/home', :action => 'index') # Login success
          end
        else
        flash[:message] = 'Please specify a valid username and password.'
        flash[:username] = params[:email]
        redirect_to '/login'
        end
      end
    # Display the appropriate login form based on subdomain
    else
      user = @session
      @account = Account.find_by_subdomain(request.subdomains.first)
      
      # Subdomain does not exist so display appropriate form
      if !@account
        redirect_to :action => "sorry"        
      end
    end
  end
  
 def forgot_password
    flash[:message] = nil
    if request.post?
      account = Account.find_by_subdomain(request.subdomains.first)
      user = User.find(:first, :conditions => ["email =? AND account_id =?", @params['email'], account.id])  
      if user
         key = user.generate_security_token
         url = url_for(:action => 'password')
         url += "?user[id]=#{user.id}&subdomain=#{user.account_id}&key=#{key}"
         Notifier.deliver_forgot_password(user, url)
         flash['message'] = "Plase check #{user.email} to change the password."
         redirect_to :action => 'index'
      else
        flash[:message] = 'Please specify a valid username.'
        render :action => 'forgot_password'
      end  
    end
  end

   def password
    flash[:message] = nil
    if request.post?
        @user = User.find(@params['id'])  
        if @user
            @user.change_password(@params['user']['password'], @params['user']['password_confirmation'])
            if @user.save
              Notifier.deliver_change_password(@user, @params['user']['password'])
              flash.now['notice'] = "New password is mailed to #{@user.email}"
              redirect_to :action => 'index'     
            else  
               flash[:message] = 'Please specify a valid username.'
               render :action => 'index'     
            end 
        else
            flash[:message] = 'Please specify a valid username.'
            render :action => 'index'     
        end
   end
  end

  def logout
    self.current_user.forget_me if self.current_user
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/login', :action => 'index')
  end
  

   def login_from_cookie
      return unless cookies['auth_token'] && @session[:user].nil?
      user = User.find_by_remember_token(*cookies['auth_token'].split(","))     
      if user && !user.remember_token_expires_at.nil? && Time.now < user.remember_token_expires_at 
         session[:user] = user
         session[:user_id] = user.id # Store current user's id
         session[:account_id] = user.account_id # Store the account id
         session[:company] = user.account.company # Store the user's company name
         session[:first_name] = user.first_name # Store user's first name
      end
   end
  
   
   def get_password_from_cookie
      user = User.find_by_email(@params['id'])  
      if user && !user.remember_token_expires_at.nil? && Time.now < user.remember_token_expires_at 
         session[:user] = user
         session[:user_id] = user.id # Store current user's id
         session[:account_id] = user.account_id # Store the account id
         session[:company] = user.account.company # Store the user's company name
         session[:first_name] = user.first_name # Store user's first name 
        @user = user
        render :partial =>  'login/get_password_from_cookie', :user => @user, :layout => false
     else
        @email   = @params['id']
        render :partial =>  'login/new_user', :email => @email, :layout => false
     end   
   end
end

class LoginController < ApplicationController

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  def login_small
    if !logged_in?
      render :action => "login/small", :layout => "login_small"
    else
      index
    end
  end

  def index    
    #Check if user is logged in and redirect to home controller if they are
    if logged_in?
      user = self.current_user
      if !user.remember_token_expires_at.nil? and Time.now < user.remember_token_expires_at
        redirect_back_or_default :controller => 'home' and return
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
        session[:email] = self.current_user.email # Store user's email
        session[:is_super_admin] = self.current_user.is_super_admin
        session[:is_admin] = (self.current_user.is_admin or self.current_user.is_super_admin)
        if params[:frm_m] == 'mobile'
          redirect_to(:controller=>'/mobile', :action=>'devices')
        else
          redirect_back_or_default(:controller => '/home', :action => 'index') # Login success
        end
        # Send them back to the login page with appropriate error message
      else
        flash[:error] = 'Please specify a valid username and password.'
        flash[:username] = params[:email]
        if params[:frm_m] == 'mobile'
          redirect_to(:controller=>'/mobile',:action=>'index')
        else
          redirect_back_or_default '/login'
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
      user = User.find(:first, :conditions => ["email =? AND account_id =?", params[:email], account.id])
      if user
        key = user.generate_security_token(80)
        user.access_key = key
        user.save
        url = url_for(:action => 'password')
        url += "?id=#{user.id}&subdomain=#{user.account_id}&key=#{key}"
        Notifier.deliver_forgot_password(user, url)
        flash[:success] = "Please check #{user.email} to change the password."
        redirect_to :action => 'index'
      else
        flash[:error] = 'Please specify a valid username.'
        render :action => 'forgot_password'
      end
    end
  end

  def password
    @user = User.find_by_id(params['id'])
    if !request.post?
      if @user.nil? || params[:key].nil? || !(@user.access_key == params[:key])
        flash[:error] = 'Invalid action.'
        redirect_to :action=>'index'
      end
    else
      if @user
        if(params['user']['password'] == params['user']['password_confirmation'] && params['user']['password'].length > 5)
          @user.change_password(params['user']['password'], params['user']['password_confirmation'])
          if @user.save
            #Notifier.deliver_change_password(@user, params['user']['password'])
            @user.access_key = nil
            @user.save
            flash[:success] = "New password is mailed to #{@user.email}"
            redirect_to :action => 'index'
          else
            flash[:error] = 'Password change failed'
            render :action => 'index'
          end
        else
          flash[:error] = "Either your password does not match or you have entered less than 6 characters."
          redirect_to  :action=>"password", :id=>@user.id, :subdomain => params[:subdomain], :key=>@user.access_key
        end
      else
        flash[:error] = 'Please specify a valid username.'
        render :action => 'index'
      end
    end
  end

  def logout
    self.current_user.forget_me if self.current_user!=:false
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    if params[:f_mb] == 'frm_mob'
      redirect_to(:controller=>'mobile',:action=>'index')
    else
      redirect_back_or_default(:controller => '/login', :action => 'index')
    end
  end

  def login_from_cookie
    return unless cookies['auth_token'] && session[:user].nil?
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

  def admin_login
    account = Account.find_by_id(cookies[:account_value])
    user = User.find_by_id(cookies[:admin_user_id])
    if account && user
      session[:from] = "admin"  # we can use this to differentiate between actual user and superamdin user & limit the access to account.
      session[:user] = user
      session[:user_id] = user.id # Store current user's id
      session[:account_id] = account.id # Store the account id
      session[:company] = account.company # Store the user's company name
      session[:first_name] = user.first_name # Store user's first name
      session[:email] = user.email # Store user's email
      session[:is_admin] = user.is_admin
      cookies[:account_value] = {:value=>"", :domain=>".#{request.domain}"}
      redirect_to(:controller => '/home', :action => 'index') # Login success
    else
      redirect_to :controller=>'login'
    end
  rescue
    flash[:error] = 'Invalid action'
    redirect_to :controller=>'login'
  end

end

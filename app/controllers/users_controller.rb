class UsersController < ApplicationController
  before_filter :authorize
  before_filter :authorize_user, :except => ['index', 'new']
  
  def index
    @current_user = User.find(session[:user_id])
    @users = User.find(:all, :conditions => ["account_id = ?", session[:account_id]])
  end
  
  def edit
    if request.post?
      user = User.find(:first, :conditions => ["id = ? and account_id = ?", params[:id], session[:account_id]])            
      user.update_attributes(params[:user])
      params[:is_admin] ? user.is_admin = 1 : user.is_admin = 0
      
      # Update the existing password
      if !params[:password_checkbox].nil?
        # First make sure the existing password is correct
        if user.crypted_password == user.encrypt(params[:password])
          # Let's verify that the new password and confirmation match
          if params[:new_password] == params[:confirm_new_password] and !params[:new_password].blank? and !params[:confirm_new_password].blank?
            user.password = params[:new_password]
            # Try and save the updated password with the user info
            if params[:new_password].length > 5
             
              user.save
              flash[:success] = user.first_name + ' ' + user.last_name + ' was updated successfully'
              redirect_to :controller => 'users'
            else # Password can't be saved
              flash[:error] = 'Passwords must be between 6 and 30 characters'
              redirect_to :controller => 'users', :action => 'edit', :id => user
            end
          else
            flash[:error] = 'Your new password and confirmation must match'
            redirect_to :controller => 'users', :action => 'edit', :id => user
          end
        else # The existing password doesn't match what's in the system
          flash[:error] = 'Your existing password must match what\'s currently stored in our system'
          redirect_to :controller => 'users', :action => 'edit', :id => user
        end
      else # Update when the password checkbox is not checked
        if user.save
          flash[:success] = user.first_name + ' ' + user.last_name + ' was updated successfully'
          redirect_to :controller => 'users'
        end
      end
    else
      @user = User.find(:first, :conditions => ["id = ? and account_id = ?", params[:id], session[:account_id]])
    end
  end


=begin
  def edit
    if request.post?
      user = User.find(:first, :conditions => ["id = ? and account_id = ?", params[:id], session[:account_id]])
      user.update_attributes(params[:user])
      params[:is_admin] ? user.is_admin = 1 : user.is_admin = 0
      
      # Update the existing password
      if !params[:password_checkbox].nil?
        # First make sure the existing password is correct
        if user.crypted_password == user.encrypt(params[:password])
          # Let's verify that the new password and confirmation match
          if params[:new_password] == params[:confirm_new_password]
            user.password = params[:new_password]
            # Try and save the updated password with the user info
            if user.save
              flash[:message] = user.first_name + ' ' + user.last_name + ' was updated successfully'
              redirect_to :controller => 'users'
            else # Password can't be saved
              flash[:message] = 'Passwords must be between 6 and 30 characters'
              redirect_to :controller => 'users', :action => 'edit', :id => user
            end
          else
            flash[:message] = 'Your new password and confirmation must match'
            redirect_to :controller => 'users', :action => 'edit', :id => user
          end
        else # The existing password doesn't match what's in the system
          flash[:message] = 'Your existing password must match what\'s currently stored in our system'
          redirect_to :controller => 'users', :action => 'edit', :id => user
        end
      else # Update when the password checkbox is not checked
        if user.save
          flash[:message] = user.first_name + ' ' + user.last_name + ' was updated successfully'
          redirect_to :controller => 'users'
        end
      end
    else
      @user = User.find(:first, :conditions => ["id = ? and account_id = ?", params[:id], session[:account_id]])
    end
  end
=end

  def new
    @user = User.new(params[:user])
    if request.post?
      @user.account_id = session[:account_id]
      if params[:is_admin]
        @user.is_admin = 1
      end
      @users = User.find(:all, :conditions => ['account_id =?', @user.account_id])
	  
	   if @users.size < 5
	      # Check that passwords match
	      if params[:user][:password] == params[:user][:password_confirmation]
          if @user.save
            flash[:success] = @user.email + ' was created successfully'
            redirect_to :controller => 'users'
          else # Display errors from model validation
            error_msg = ''
            @user.errors.each_full do |error|
              error_msg += error + '<br />'
            end
            flash[:error] = error_msg
          end
        else
          flash[:error] = 'Your new password and confirmation must match'
        end
      else
        flash[:error] = "There are already 5 users in this account"
      end  
    end
  end
  
  def delete
    if request.post?
     user = User.find(params[:id])
     if user.is_master == false   
        user.destroy
        flash[:success] = user.email + ' was deleted successfully'
        redirect_to :controller => "users"
      else  
        flash[:error] = 'Master user cannot be deleted'
        redirect_to :controller => "users"
      end  
    end
  end
end

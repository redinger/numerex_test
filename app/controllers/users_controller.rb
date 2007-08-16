class UsersController < ApplicationController
  before_filter :authorize
 
  
  def index
    @current_user = User.find(session[:user_id])
    @users = User.find(:all, :conditions => ["account_id = ?", session[:account_id]])
  end
  
  def edit
    if request.post?
      user = User.find(params[:id])
      user.update_attributes(params[:user])
      params[:is_admin] ? user.is_admin = 1 : user.is_admin = 0
      
      if user.save
        flash[:message] = user.first_name + ' ' + user.last_name + ' was updated successfully'  
        redirect_to :controller => "users"
      end
    else
      @user = User.find(params[:id]) 
    end
  end
  
  def new
    if request.post?
      user = User.new(params[:user])
      user.account_id = session[:account_id]
      if params[:is_admin]
        user.is_admin = 1
      end
      @users = User.find(:all, :conditions => ['account_id =?', user.account_id])
	  
	   if @users.size < 5
        begin
          user.save!
          flash[:message] = user.email + ' was created successfully'
          redirect_to :controller => "users"
        rescue ActiveRecord::RecordInvalid
            flash[:message] = "There were errors in creating your account. Please review the form below."
        end
      else
        flash[:message] = "There are already 5 users in this account"
      end  
    end
  end
  
  def delete
    if request.post?
     user = User.find(params[:id])
     if user.is_master == false   
        user.destroy
        flash[:message] = user.email + ' was deleted successfully'
        redirect_to :controller => "users"
      else  
        flash[:message] = 'Master user cannot be deleted'
        redirect_to :controller => "users"
      end  
    end
  end
end

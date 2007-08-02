class UsersController < ApplicationController
  before_filter :authorize
  
  def index
    @current_user = User.find(session[:user_id])
    @users = User.find(:all, :conditions => ["account_id = ?", session[:account_id]])
  end
  
  def edit
    if request.post?
      user = User.find(params[:id])
      params[:is_admin] ? params[:user][:is_admin] = 1 : params[:user][:is_admin] = 0
      user.update_attributes(params[:user])
      flash[:message] = user.first_name + ' ' + user.last_name + ' was updated successfully'      
      redirect_to :controller => "users"
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
      
      if user.save!
        flash[:message] = user.email + ' was created successfully'
        redirect_to :controller => "users"
      end
      
    end
  end
  
  def delete
    if request.post?
      user = User.find(params[:id])
      user.destroy
      flash[:message] = user.email + ' was deleted successfully'
      redirect_to :controller => "users"
    end
  end
end

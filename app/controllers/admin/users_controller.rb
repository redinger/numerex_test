class Admin::UsersController < ApplicationController
  before_filter :authorize_super_admin
  layout 'admin'
  def index
     if params[:id]
        @users = User.find(:all, :order => "last_name", :conditions => ["account_id = ?", params[:id]])
      else
        @users = User.find(:all, :order => "last_name")
      end
      @accounts = Account.find(:all, :order => "company")
  end

  def show
  end

  def new
    @user = User.new
    @accounts = Account.find(:all, :order => "company")
  end

  def edit
    @user = User.find(params[:id])
    @accounts = Account.find(:all, :order => "company")
  end

  def create
    @user = User.new(params[:user])
    if request.post?
      @users = User.find(:all, :conditions => ['account_id =?', @user.account_id])
      
      # If this is the first user for this account make them the master
      if @users.size == 0
        @user.is_master = 1
      end
	  
      # Check that passwords match
      if params[:user][:password] == params[:user][:password_confirmation]
        if @user.save
          flash[:success] = @user.email + ' was created successfully'
          redirect_to :action => "index" and return
        else # Display errors from model validation
          error_msg = ''
          @user.errors.each_full do |error|
            error_msg += error + '<br />'
          end
          flash[:error] = error_msg
          redirect_to :action => "new" and return
        end
      else
        flash[:error] = 'Your new password and confirmation must match'
        redirect_to :action => "new" and return
      end
    end 
  end

  def update
    if request.post?
      @user = User.find(params[:id])
      @user.update_attributes(params[:user])
      
      if @user.save
        flash[:success] = "#{@user.email} updated successfully"
        redirect_to :action => 'index' and return
      else
        error_msg = ''
        @user.errors.each_full do |error|
          error_msg += error + '<br />'
        end
        flash[:error] = error_msg
        redirect_to :action => 'edit', :id => @user.id and return
      end
    end
  end

  def destroy
    if request.post?
      user = User.find(params[:id])
      user.destroy
      flash[:success] = "#{user.email} deleted successfully"
    end
    redirect_to :action => "index"
  end
end

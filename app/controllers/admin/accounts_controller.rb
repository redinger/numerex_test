class Admin::AccountsController < ApplicationController
  before_filter :authorize_super_admin
  layout 'admin'
  
  helper_method :encode_account_options
  
  def encode_account_options(account)
    (account.show_idle ? "I" : "-") + (account.show_runtime ? "R" : "-") + (account.show_statistics ? "S" : "-") + (account.show_maintenance ? "M" : "-")
  end
  
  def index
    @accounts = Account.find(:all, :order => "subdomain", :conditions => "is_deleted=0")
  end

  def new
    @account = Account.new
  end

  def edit
    @account = Account.find(params[:id])
  end

  def create
    if request.post?
      account = Account.new(params[:account])
      apply_options_to_account(params,account)
      account.is_verified = 1
      
      if account.save
        flash[:success] = "#{account.subdomain} created successfully"
        redirect_to :action => 'index' and return
      else
        error_msg = ''
        
        account.errors.each{ |field, msg|
          error_msg += msg + '<br />'
        }
        
        flash[:error] = error_msg
        redirect_to :action => 'new' and return
      end
    end
  end

  def subdomain_login
      user_account = Account.find_by_id(params[:id])                      
      if  !user_account.nil?   #No need to check for super_admin because of before_filter "authorize_super_admin"
         cookies[:account_value] = { :value => "#{user_account.id}", :domain => ".#{request.domain}"} 
         cookies[:admin_user_id] = { :value => "#{session[:user_id]}", :domain => ".#{request.domain}"} 
         redirect_to("http://#{user_account.subdomain}.#{request.domain}:#{request.port}/login/admin_login")
      else
         redirect_to :controller=>'/home', :action=>'index'
      end
  end
 
  def update
    if request.post?
      account = Account.find(params[:id])
      previous_allow_speed_exceptions = account.allow_speed_exceptions
      apply_options_to_account(params,account)
      previous_max_speed = account.max_speed
      if account.update_attributes(params[:account])
        if previous_max_speed.to_s != account.max_speed.to_s or (previous_allow_speed_exceptions and not account.allow_speed_exceptions)
          previous_condition = (previous_max_speed ? " and max_speed = #{previous_max_speed}" : " and max_speed is null") if account.allow_speed_exceptions
          Account.connection.execute("update devices set max_speed = #{account.max_speed or 'null'} where account_id = #{account.id}#{previous_condition}")
        end
        flash[:success] = "#{account.subdomain} updated successfully"
        redirect_to :action => 'index' and return
      else
        error_msg = ''
        
        account.errors.each{ |field, msg|
          error_msg += msg + '<br />'
        }
        
        flash[:error] = error_msg
        redirect_to :action => 'edit', :id => account.id and return
      end
    end
  end

  
  def destroy
    if request.post?
      account = Account.find(params[:id])
      account.update_attribute(:is_deleted, 1)
      account.save
      flash[:success] = "#{account.subdomain} deleted successfully"
    end
    redirect_to :action => 'index'
  end


private
  def apply_options_to_account(params,account)
    update_attributes_with_checkboxes(account,[:allow_speed_exceptions,:show_idle,:show_runtime,:show_statistics,:show_maintenance],params[:options])
   end

end

class Admin::AccountsController < ApplicationController
  before_filter :authorize_super_admin
  layout 'admin'
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

  def update
    if request.post?
      account = Account.find(params[:id])
      account.update_attributes(params[:account])
      
      if account.save
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
end

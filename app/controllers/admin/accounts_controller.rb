class Admin::AccountsController < ApplicationController
  layout 'admin'
  def index
    @accounts = Account.find(:all, :order => "subdomain", :conditions => "is_deleted=0")
  end

  def show
    @account = Account.find(params[:id])
  end

  def new
    @account = Account.new
  end

  def edit
    @account = Account.find(params[:id])
  end

  def create
    account = Account.new(params[:account])
    account.is_verified = 1
    account.save
    flash[:message] = "#{account.subdomain} created successfully"
    redirect_to :action => 'index'
  end

  def update
    account = Account.find(params[:id])
    account.update_attributes(params[:account])
    account.save
    flash[:message] = "#{account.subdomain} updated successfully"
    redirect_to :action => 'index'
  end

  def destroy
    account = Account.find(params[:id])
    account.update_attribute(:is_deleted, 1)
    account.save
    flash[:message] = "#{account.subdomain} deleted successfully"
    redirect_to :action => 'index'
  end
end
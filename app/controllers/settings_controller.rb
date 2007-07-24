class SettingsController < ApplicationController
  def index
    @account = Account.find(session[:account_id])    
    if request.post?
      @account.company = params[:company]
      @account.save
      session[:company] = params[:company]
      redirect_to :action => 'index'
    end
  end
end

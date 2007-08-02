class SettingsController < ApplicationController
  def index
    @account = Account.find(session[:account_id])   
    @user = User.find(session[:user_id])
    if request.post?
      @account.update_attribute('company', params[:company])
      params[:notify] ? params[:notify] = 1 : params[:notify] = 0
      @user.update_attributes!(:time_zone => params[:time_zone], :enotify => params[:notify])
      
      session[:company] = params[:company]
      flash[:message] = 'Settings saved successfully'
      redirect_to :action => 'index'
    end
  end
end

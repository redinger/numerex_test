class SettingsController < ApplicationController
  def index
    @account = Account.find(session[:account_id])
    @user = User.find(session[:user_id])
    @groups = Group.find(:all,:conditions=>["account_id=?",session[:account_id]])
    if request.post?
      if session[:is_admin]
        @account.update_attribute('company', params[:company])
        session[:company] = params[:company]
      end
      params[:time_zone] = NIL if params[:time_zone] == ''
      @user.update_attributes!(:time_zone => params[:time_zone], :enotify => params[:notify])
      update_group_notifications if @user.enotify == 2
      flash[:success] = 'Settings saved successfully'
      redirect_to :action => 'index'
    end
  end

  def  update_group_notifications
    for group in @groups
      GroupNotification.delete_all "user_id = #{@user.id} AND group_id = #{group.id}"
      if params["rad_grp#{group.id}"]
        group_notification = GroupNotification.new
        group_notification.user_id = @user.id
        group_notification.group_id = params["rad_grp#{group.id}"]
        group_notification.save
      end
    end
  end

end

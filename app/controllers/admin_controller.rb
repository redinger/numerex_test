class AdminController < ApplicationController
  before_filter :authorize_super_admin
  
  def index
    @total_accounts = Account.count(:conditions => "is_deleted = 0")
    @total_users = User.count 
    @total_devices = Device.count(:conditions => "provision_status_id = 1")
  end
  
end

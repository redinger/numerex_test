class AdminController < ApplicationController

  def index
    @total_accounts = Account.count 
    @total_devices = Device.count
  end
  
end

class AdminController < ApplicationController
  before_filter :authorize_admin

  def index
    @devices = Device.find(:all) # Get devices associated with account
  end
end

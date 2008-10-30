class XirgoController < ApplicationController
  before_filter :authorize_super_admin
  layout 'admin'
  
  def index
    @total_devices = Xirgo::Device.count
    @total_requests = Xirgo::CommandRequest.count
  end
  
end

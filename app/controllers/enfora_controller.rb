class EnforaController < ApplicationController
  before_filter :authorize_super_admin
  layout 'admin'
  
  def index
    @total_devices = Enfora::Device.count
    @total_requests = Enfora::CommandRequest.count
  end
  
end

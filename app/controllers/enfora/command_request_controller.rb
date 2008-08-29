class Enfora::CommandRequestController < Enfora::CommonController

  def compose
    @command_request = Enfora::CommandRequest.new(:device_id => params[:id])
  end
  
  def submit
    @command_request = Enfora::CommandRequest.new(params[:command_request])
    @command_request.start_date_time = Time.now
    @command_request.save!
    redirect_to :action => "check_status",:id => @command_request
  rescue
    @error = $!.to_s
    @command_request ||= Enfora::CommandRequest.new
  end
  
  def list
    @device = Device.find(params[:id]) if params[:id]
    @device ||= Device.new
    conditions = "device_id = #{@device.id}" if @device.id
    @command_requests = Enfora::CommandRequest.find(:all,:conditions => conditions,:order => "start_date_time desc")
  end
  
  def check_status
    @command_request = Enfora::CommandRequest.find(params[:id])
    @device = (@command_request.device or Device.new)
  rescue
    @error = $!.to_s
    @command_request ||= Enfora::CommandRequest.new
    @device ||= Device.new
  end
end

class Xirgo::DeviceController < Xirgo::CommonController
  def list
    @selections = {}
    @devices = Xirgo::Device.find(:all,:order => "imei")
    return if request.get?
    if params[:device_ids]
      for device_id in params[:device_ids]
        selected_device = Xirgo::Device.find(device_id)
        raise "Xirgo::Device not found: #{device_id}" unless selected_device
        @selections[selected_device.id] = selected_device
      end
    end
    raise "No command specified" unless params[:XT3001] and !params[:XT3001].blank?
    raise "No devices selected" if @selections.empty?
    
    commands = {}
    commands["+XT:3001"] = params[:XT3001]
    commands["+XT:3002"] = params[:XT3002]
    commands["+XT:3003"] = params[:XT3003]
    commands["+XT:3004"] = params[:XT3004]
    commands["+XT:3005"] = params[:XT3005]
    commands["+XT:3006"] = params[:XT3006]
    commands["+XT:3007"] = params[:XT3007] + "," + params[:XT3007]
    
    Xirgo::CommandRequest.transaction do
      start_date_time = Time.now
      @selections.each_value do |device|
        commands.each do |command, value|
          if value != ""
            command_request = Xirgo::CommandRequest.new
            command_request.device_id = device.id
            command_request.imei = device.imei
            command_request.command = command + "," + value
            command_request.start_date_time = start_date_time
            command_request.save!
          end
        end
      end
    end
    redirect_to :controller => 'command_request',:action => 'list'
  rescue
    test = $!.to_s
    @error = $!.to_s
  end
end

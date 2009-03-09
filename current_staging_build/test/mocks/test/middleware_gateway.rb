require 'lib/middleware_gateway'

class Middleware_Gateway
  
  def Middleware_Gateway.send_AT_cmd(command, device)
    puts "sending: " + command + " to device: " + device.name
  end
  
end
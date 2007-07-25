class Middleware_Gateway
  
  def Middleware_Gateway.send_AT_cmd(command, device)
     url = 'http://localhost:8080/webservice/simple/at.ws?cmd=' + command + '&device=' + device.imei
     Net::HTTP.get_response(URI.parse(url))
  end
  
end
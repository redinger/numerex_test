require 'soap/wsdlDriver'

class Text_Message_Webservice
  
  REG_KEY = "EA792DD474E88BE770F1"
  WSDL = "http://wsparam.strikeiron.com/globalsmspro2_5?WSDL"

  def Text_Message_Webservice.send_message(to, text)
    begin
      driver = SOAP::WSDLDriverFactory.new(WSDL).create_rpc_driver
      @results = driver.SendMessage(:UserID => REG_KEY, :ToNumber => to, :MessageText => text).sendMessageResult.messageStatus
      puts @results.statusCode
      puts @results.statusText
      puts @results.statusExtra
      if(@results.statusCode==1 || @results.statusCode==2) 
        return true
      else
        return false
      end
      
    rescue
      return false
    end
      return true
  end
end
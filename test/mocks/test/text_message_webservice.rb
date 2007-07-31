require 'lib/Text_Message_Webservice'

class Text_Message_Webservice
  
  def Text_Message_Webservice.send_message(to, text)
    puts "sending " + text + "\nto: " + to
  end
end
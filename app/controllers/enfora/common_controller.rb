class Enfora::CommonController < ApplicationController
  before_filter :authorize_super_admin
  layout 'admin'

  helper_method :predefined_command_options

  def predefined_command_options
    result = []
    result.push("<option>Select command...</option>")
    result.push(predefined_command_option("AT"))
    result.push(predefined_command_option("AT+CGMI"))
    result.push(predefined_command_option("AT+CGSN"))
    result.push(predefined_command_option("AT+CGREG"))
    result.join
  end

  def predefined_command_option(command)
    "<option value='#{command}'>#{command}</option>"
  end
end

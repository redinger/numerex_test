require 'enfora/device'
require 'enfora/command_request'

enfora_spec = YAML::load_file("#{RAILS_ROOT}/config/enfora_gateway.yml")[ENV["RAILS_ENV"]]
Enfora::Device.establish_connection(enfora_spec)
Enfora::CommandRequest.establish_connection(enfora_spec)

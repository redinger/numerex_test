require 'xirgo/device'
require 'xirgo/command_request'

xirgo_spec = YAML::load_file("#{RAILS_ROOT}/config/xirgo_gateway.yml")[ENV["RAILS_ENV"]]
Xirgo::Device.establish_connection(xirgo_spec)
Xirgo::CommandRequest.establish_connection(xirgo_spec)

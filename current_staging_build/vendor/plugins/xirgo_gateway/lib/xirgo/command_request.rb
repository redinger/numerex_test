require 'xirgo/device'

class Xirgo::CommandRequest < ActiveRecord::Base
  set_table_name "outbound"
  
  belongs_to :device
end

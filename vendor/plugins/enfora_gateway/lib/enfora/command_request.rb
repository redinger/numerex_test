require 'enfora/device'

class Enfora::CommandRequest < ActiveRecord::Base
  set_table_name "outbound"
  
  belongs_to :device
end

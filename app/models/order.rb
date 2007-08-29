class Order < ActiveRecord::Base
  attr_accessor :ship_first_name
  validates_presence_of :ship_first_namew
  
  
  
end

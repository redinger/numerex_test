class Group < ActiveRecord::Base
 belongs_to :account
 has_many :devices
 include ApplicationHelper 
 
 validates_presence_of :name
end

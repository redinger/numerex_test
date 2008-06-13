class Group < ActiveRecord::Base
 belongs_to :account
 has_many :devices, :conditions => "provision_status_id = 1"
 include ApplicationHelper
 
 validates_presence_of :name
end

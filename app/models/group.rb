class Group < ActiveRecord::Base
belongs_to :group_device
 validates_presence_of :name
end

class GroupDevice < ActiveRecord::Base
belongs_to :group
validates_presence_of :device_id
belongs_to :device
end

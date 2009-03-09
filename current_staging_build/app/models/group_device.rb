class GroupDevice < ActiveRecord::Base
  belongs_to :group
  belongs_to :device
  validates_presence_of :device_id
end

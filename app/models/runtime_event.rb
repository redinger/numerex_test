class RuntimeEvent < ActiveRecord::Base
  belongs_to :reading
  belongs_to :device
end

class Device < ActiveRecord::Base
  has_many :readings, :order => "created_at desc", :limit => 25
end

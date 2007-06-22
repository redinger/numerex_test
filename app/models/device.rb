class Device < ActiveRecord::Base
  belongs_to :account
  has_many :readings, :order => "created_at desc", :limit => 10
  
  def self.get_devices
    find(:all, :conditions => ['provision_status_id = 1'])
  end
end

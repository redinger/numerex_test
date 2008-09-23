class Account < ActiveRecord::Base
  has_many :devices
  has_many :users
  has_many :groups
  validates_uniqueness_of :subdomain, :case_sensitive => false
  validates_presence_of :zip, :message => "Please specify your zip code"
  validates_presence_of :company, :message => "Please specify your company or group name"
  validates_presence_of :subdomain, :message => "Please specify a subdomain"
  
  def speed_exceptions
    @speed_exceptions ||= Device.find(:all,:conditions => "account_id = #{self.id} and max_speed #{self.max_speed ? '!= ' + self.max_speed.to_s : 'is not null'}")
  end
end

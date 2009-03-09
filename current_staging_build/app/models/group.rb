class Group < ActiveRecord::Base
  belongs_to :account
  has_many :devices, :conditions => "provision_status_id = 1"
  has_many :group_notifications
  include ApplicationHelper
 
  validates_presence_of :name
 
  def is_selected_for_notification(user)
    group_notification = GroupNotification.find(:first, :conditions=>['user_id = ? and group_id = ?',user.id,self.id]) 
    if group_notification.nil?
      return false
    else
      return true
    end    
  end    
  
  def ordered_devices
    Device.find(:all, :conditions=>['provision_status_id = 1 and group_id=?',self.id], :order=>'name')
  end
  
end

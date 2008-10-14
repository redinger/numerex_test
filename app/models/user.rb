require 'digest/sha1'
class User < ActiveRecord::Base
  belongs_to :account
  attr_accessor :password
  validates_presence_of :first_name, :last_name, :email
  validates_uniqueness_of :email, :scope => :account_id # No dupes within account
  validates_confirmation_of :password
  validates_length_of :password, :within => 6..30, :if => :password_required?
  before_save :encrypt_password
  
  TimeZoneMapping = {
        "Pacific Time (US & Canada)"   => "America/Los_Angeles",
        "Hawaii"                       => "Pacific/Honolulu",
        "Alaska"                       => "America/Juneau",
        "Arizona"                      => "America/Phoenix",
        "Mountain Time (US & Canada)"  => "America/Denver",
        "Central Time (US & Canada)"   => "America/Chicago",
        "Eastern Time (US & Canada)"   => "America/New_York",
        "Indiana (East)"               => "America/Indiana/Indianapolis"        
     } 
  
  # Authenticates a user by subdomain, email and unencrypted password.  Returns the user or nil.
  #def self.authenticate(email, password)
  def self.authenticate(subdomain, email, password)
    
    account = Account.find_by_subdomain(subdomain)
    user = find_by_email_and_account_id(email, account.id )
    
    
    
    if (user && user.authenticated?(password) && user.account.is_verified)
      user.update_attribute(:last_login_dt, Time.now)
      user
    else
      nil # User does not belong
    end
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end
  
  def generate_security_token(size=25)          
         s = ""
         size.times { s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
         s     
   end
     
  def group_devices_ids
      devices_ids=[]
      selected_groups = GroupNotification.find(:all, :conditions=>['user_id = ?',self.id])
      for group in selected_groups
         devices = Device.find(:all, :conditions=>["group_id = ?",group.group_id]).each{|dev| devices_ids << dev.id}
      end
      return devices_ids
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 1.day.from_now
    self.remember_token = Digest::SHA1.hexdigest("#{salt}--#{self.email}--#{self.remember_token_expires_at}")
    self.password = "" # This bypasses password encryption, thus leaving password intact
    self.save_with_validation(false)
  end
  
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token = nil
    self.password = "" # This bypasses password encryption, thus leaving password intact
    self.save_with_validation(false)
  end

  def change_password(pass, confirm)
    self.password = pass
    self.password_confirmation = confirm
    @new_password = true
  end
  
  def get_time_zone
       TimeZoneMapping["#{self.time_zone}"]
  end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end

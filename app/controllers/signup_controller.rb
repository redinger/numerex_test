class SignupController < ApplicationController

  # Displays the signup form
  def index
    redirect_to 'http://www.ublip.com/pricing'
    #@user = User.new
    #@user.account = Account.new
  end
  
  def create
    # We must create the account first and then associate a user with it
    @user = User.new(params[:user])
    @user.is_admin = 1
    @user.is_master = 1
    @user.account = Account.new(params[:account])
    @user.account.subdomain.downcase
    
    if @user.save && @user.account.save
      key = @user.encrypt(@user.created_at.to_i)
      begin
        Mailer.deliver_registration_confirmation(@user, key)
      rescue 
        flash[:message] = "There was a temporary problem creating your account, please try again later."
        render_action "index"
        @user.account.destroy
        @user.destroy
        return
      end
      redirect_to :controller => 'signup', :action => 'create_thanks'
    else
      flash[:message] = "There were errors in creating your account.  Please review the form below."
      render_action "index"
      @user.account.destroy
      @user.destroy
    end
  end
  
  # Creation complete.  An email is dispatched asking them to verify their account.
  def create_thanks 
  end
  
  # A user registers, receives an email, and then clicks the link to verify their account
  def verify
    user = User.find(params[:id])
    
    # Account is already verified so redirect them to their subdomain
    if user.account.is_verified
      redirect_to 'http://' + user.account.subdomain + '.ublip.com' and return
    end
    
    # Keys match, verify and redirect to subdomain
    if user.encrypt(user.created_at.to_i).eql?(params[:key])
      user.account.is_verified = 1
      user.account.save
      redirect_to 'http://' + user.account.subdomain + '.ublip.com' and return
    # Keys do not match, redirect to homepage
    else
      redirect_to 'http://www.ublip.com' and return
    end
  end
  
end

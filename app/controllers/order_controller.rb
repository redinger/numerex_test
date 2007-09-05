class OrderController < ApplicationController
  def index
   render :action => 'step1'
  end
  
  # User will specify billing, shipping, and login info
  def step1
  end

  # Validate fields from step 1 and display shipping, tax, and cc stuff
  # Make certain that the web address doesn't already exist
  def step2
    # Store their information to the session object
    session[:cust] = params[:cust]
    session[:email] = params[:email]
    session[:password] = params[:password]
    session[:subdomain] = params[:subdomain]
    # See if the subdomain already exists
    subdomain = Account.find_by_subdomain(params[:subdomain])
    # The subdomain already exists so redirect them and display error
    if(!subdomain.nil?)
      flash[:error] = "We're sorry, this web address already exists.  Please try another."
      redirect_to :action => 'index'
    end
    
  end
  
  # Paypal authorization
  def complete
    
    
  end
  
  private
  def find_session
    session[:order]
  end
end

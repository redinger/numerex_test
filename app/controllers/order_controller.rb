class OrderController < ApplicationController
  def index
   render :action => 'step1'
  end
  
  # User will specify billing, shipping, and login info
  def step1
  end

  # Validate fields from step 1 and display shipping, tax, and cc stuff
  def step2
    #order = Order.new
    #account = Account.new
    #account.
    
    
  end
  
  # Paypal authorization
  def complete
    
  end
end

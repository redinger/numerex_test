class OrderController < ApplicationController
  def index
   redirect_to :action => 'step1'
  end
  
  # User will specify billing, shipping, and login info
  def step1
    if params[:product_code]
      session[:product_code] = params[:product_code]
      session[:subtotal] = params[:cost] * params[:qty]
    else
      session[:product_code] = "UB1000"
      session[:subtotal] = 264.90
    end
  end

  # Validate fields from step 1 and display shipping, tax, and cc stuff
  # Make certain that the web address doesn't already exist
  def step2
    # Store their information to the session object
    session[:cust] = params[:cust]
    session[:email] = params[:email]
    session[:password] = params[:password]
    session[:subdomain] = params[:subdomain]
    
    # Determine shipping costs
    ship_ground = 12.95
    ship_2day = 24.95
    ship_overnight = 49.95
        
    
    # See if the subdomain already exists
    subdomain = Account.find_by_subdomain(params[:subdomain])
    # The subdomain already exists so redirect them and display error
    if(!subdomain.nil?)
      flash[:error] = "We're sorry, this web address already exists.  Please try another."
      redirect_to :action => 'index'
    end
    
  end
  
  # PayPal authorization
  def complete
    # Calculate charges based on product (annual or yearly) and quantity
    qty = params[:qty].to_i
    
    

    # Create the PayPal request object
    req= {
      :method          => 'DoDirectPayment',
      :amt             => '295.70',
      :currencycode    => 'USD',
      :paymentaction   => 'authorization',
      :creditcardtype  => 'Visa',
      :acct            => '4721930402892796',
      :firstname       => 'Dennis',
      :lastname        => 'Baldwin',
      :email           => 'dennis@ublip.com',
      :street          => '6246 Ellsworth Avenue',
      :city            => 'Dallas',
      :state           => 'TX',
      :zip             => '75214',
      :countrycode     => 'US',
      :expdate         => '122010',
      :cvv2            => '396',
      :shiptoname      => 'Dennis Baldwin',
      :shiptostreet    => '6246 Ellsworth Avenue',
      :shiptostreet2   => '',
      :shiptocity      => 'Dallas',
      :shiptostate     => 'TX',
      :shiptocountrycode => 'US',
      :shiptophonenum  => '2147383404',
      :shiptozip       => '75214',
      :itemamt         => '264.90',
      :shippingamt     => '12.95',
      :taxamt          => '21.85',
      :l_name0         => 'Ublip Tracking Device',
      :l_number0       => 'UD1000',
      :l_qty0          => '1',
      :l_amt0          => '249.95',
      :l_name1         => 'Ublip Monthly Tracking Service',
      :l_number1       => 'US1000',
      :l_qty1          => '1',
      :l_amt1          => '14.95'  
    }
    
    
    
  end
  
end

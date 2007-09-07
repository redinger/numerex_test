class OrderController < ApplicationController
  def index
   redirect_to :action => 'step1'
  end
  
  # User will specify billing, shipping, and login info
  def step1
    if params[:device_code] # The form data exists - clear the cust data
      session[:cust] = session[:email] = session[:password] = session[:subdomain] = nil
      session[:device_code] = params[:device_code]
      session[:device_price] = params[:device_price]
      session[:service_code] = params[:service_code]
      session[:service_price] = params[:service_price]
      session[:qty] = params[:qty].to_i
      session[:subtotal] = (params[:device_price].to_f + params[:service_price].to_f) * params[:qty].to_i
    elsif session[:device_code].nil? # The form and session data do not exist
      session[:device_code] = "UD1000"
      session[:device_price] = 249.95
      session[:service_code] = "US1000"
      session[:service_price] = 14.95
      session[:qty] = 1
      session[:subtotal] = 264.90
    end
    
    #Estimated shipping
    if session[:qty] > 1
      @ship_ground = 12.95 + (session[:qty]*4.95)
    else
      @ship_ground = 12.95
    end
  end

  # Validate fields from step 1 and display shipping, tax, and cc stuff
  # Make certain that the web address doesn't already exist
  def step2

    # See if the subdomain already exists
    subdomain = Account.find_by_subdomain(params[:subdomain])
    # The subdomain already exists so redirect them and display error
    if(!subdomain.nil?)
      flash[:error] = "We're sorry, this web address already exists.  Please try another."
      redirect_to :action => 'step1'
    end
    
    # Store their information to the session object
    session[:cust] = params[:cust]
    session[:email] = params[:email]
    session[:password] = params[:password]
    session[:subdomain] = params[:subdomain]
    
    # Determine shipping costs
    @ship_ground = 12.95
    @ship_2day = 24.95
    @ship_overnight = 49.95
    
    # Do the multiplier based on qty
    if session[:qty].to_i > 1
      @ship_ground = @ship_ground + (session[:qty]*4.95)
      @ship_2day = @ship_2day + (session[:qty]*7.95)
      @ship_overnight = @ship_overnight + (session[:qty]*9.95)
    end
    
    # Determine tax
    if params[:cust][:ship_state] == 'TX'
      @tax = (session[:subtotal] * 0.0825)
      session[:tax] = @tax
    else
      @tax = 0
    end
    
    session[:total] = session[:subtotal] + @ship_ground + @tax
  end
  
  # PayPal authorization
  def process_order
    # Calculate charges based on product (annual or yearly) and quantity
    qty = session[:qty]
    
    

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
    
    # If paypal success then complete the order
    redirect_to :action => 'complete'
    
    # If not send them back to step 2 and provide proper feedback
  end
  
  def complete
    # Send email acknowledgement
  end
  
end

class OrderController < ApplicationController
  filter_parameter_logging :cc_type, :cc_number, :cvv2, :cc_month, :cc_year
  
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
      session[:service_price] = 19.95
      session[:qty] = 1
      session[:subtotal] = 269.90
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
    
    # If billing info is same as shipping then copy over
    if params[:bill_toggle]
      params[:cust][:bill_first_name] = params[:cust][:ship_first_name]
      params[:cust][:bill_last_name] = params[:cust][:ship_last_name]
      params[:cust][:bill_company] = params[:cust][:ship_company]
      params[:cust][:bill_address] = params[:cust][:ship_address]
      params[:cust][:bill_address2] = params[:cust][:ship_address2]
      params[:cust][:bill_city] = params[:cust][:ship_city]
      params[:cust][:bill_state] = params[:cust][:ship_state]
      params[:cust][:bill_zip] = params[:cust][:ship_zip]
    end
   
    # Store their information to the session object, but not when redirected back from process_order
    if params[:cust]
      session[:cust] = params[:cust]
      session[:email] = params[:email]
      session[:password] = params[:password]
      session[:subdomain] = params[:subdomain]
    end
    
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
    if session[:cust][:ship_state] == 'TX'
      tax = (session[:subtotal] * 0.0825)
      session[:tax] = tax
    else
      session[:tax] = 0
    end
    
    # Store the total
    session[:total] = session[:subtotal] + @ship_ground + session[:tax]
  end
  
  # PayPal authorization
  def process_order
    
    # Create the PayPal request object
    req= {
      :method          => 'DoDirectPayment',
      :amt             => params[:total],
      :currencycode    => 'USD',
      :paymentaction   => 'authorization',
      :creditcardtype  => params[:cc_type],
      :acct            => params[:cc_number].strip,
      :firstname       => session[:cust][:bill_first_name].strip,
      :lastname        => session[:cust][:bill_last_name].strip,
      :email           => session[:email].strip,
      :street          => session[:cust][:bill_address].strip,
      :city            => session[:cust][:bill_city].strip,
      :state           => session[:cust][:bill_state],
      :zip             => session[:cust][:bill_zip].strip,
      :countrycode     => 'US',
      :expdate         => params[:cc_month] + params[:cc_year],
      :cvv2            => params[:cvv2].strip,
      :shiptoname      => session[:cust][:ship_first_name].strip + ' ' + session[:cust][:ship_last_name].strip,
      :shiptostreet    => session[:cust][:ship_address].strip,
      :shiptostreet2   => session[:cust][:ship_address2].strip,
      :shiptocity      => session[:cust][:ship_city].strip,
      :shiptostate     => session[:cust][:ship_state],
      :shiptocountrycode => 'US',
      :shiptozip       => session[:cust][:ship_zip].strip,
      :itemamt         => params[:subtotal],
      :shippingamt     => params[:shipping],
      :taxamt          => params[:tax],
      :l_name0         => 'Ublip Tracking Device',
      :l_number0       => session[:device_code],
      :l_qty0          => session[:qty],
      :l_amt0          => session[:device_price],
      :l_name1         => 'Ublip Tracking Service',
      :l_number1       => session[:service_code],
      :l_qty1          => session[:qty],
      :l_amt1          => session[:service_price],
      :ipaddress       => request.env['REMOTE_ADDR']
    }
    
    # Initialize the PayPal object
    caller = PayPalSDKCallers::Caller.new(false)
    
    # Create the PayPal transaction
    transaction = caller.call(req)
    
    # Save the response so we can display the appropriate message
    session[:paypal_response] = flash[:paypal_response] = transaction.response
    
    # Transaction successful
    if transaction.success?
      # Set a default company/group name if it doesn't exist
      if session[:cust][:ship_company] == ''
        company = 'My'
      else
        company = session[:cust][:ship_company]
      end

      # Create the user and account
      user = User.new(:first_name => session[:cust][:ship_first_name], :last_name => session[:cust][:ship_last_name], :email => session[:email], :password => session[:password], :is_admin => 1, :is_master => 1)
      user.account = Account.new(:subdomain => session[:subdomain].strip.downcase, :company => company, :city => session[:cust][:ship_city], 
                            :state => session[:cust][:ship_state], :zip => session[:cust][:ship_zip], :is_verified => 1)
      user.save
      
      # Send the email confirmation
      order_details = {:qty => session[:qty], :shipping => params[:shipping], 
                    :subtotal => params[:subtotal], :tax => params[:tax], :total => params[:total],
                    :service_code => session[:service_code], :service_price => session[:service_price]}
                      
      Notifier.deliver_order_confirmation(transaction.response["TRANSACTIONID"], 
                 session[:cust], order_details, session[:email], session[:password], session[:subdomain])      

      redirect_to :action => 'complete'
    # Failed transaction
    else
      # Store the shipping_index so we can maintain the selection when redirected back
      flash[:shipping_index] = params[:shipping_index]
      redirect_to :action => 'step2'
    end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    
  end

  # Order completed successfully
  def complete
    @email = session[:email]
    # Clear the session
    reset_session
  end
  
end

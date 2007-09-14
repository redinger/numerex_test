require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/paypal/lib/caller'
require File.dirname(__FILE__) + '/../../vendor/plugins/paypal/lib/profile'

class OrderTest < Test::Unit::TestCase
  def setup
      @caller = PayPalSDKCallers::Caller.new(false)
      @shipping = 8.95
  end
  def test_do_direct_payment_monthly
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
          :shippingamt     => @shipping,
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
      # Need to determine how this can use the test API credentials and not production when we go live
      #@transaction = @caller.call(req)
      #puts @transaction.response
      #assert_equal 'Success', @transaction.response["ACK"].to_s       
 end

  def test_do_direct_payment_yearly
      req= {
            :method          => 'DoDirectPayment',
            :amt             => '441.80',
            :currencycode    => 'USD',
            :paymentaction   => 'authorization',
            :creditcardtype  => 'MasterCard',
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
            :itemamt         => '399.95',
            :shippingamt     => @shipping,
            :taxamt          => '32.90',
            :l_name0         => 'Ublip Tracking Device',
            :l_number0       => 'UD1000',
            :l_qty0          => '1',
            :l_amt0          => '249.95',
            :l_name1         => 'Ublip Annual Tracking Service',
            :l_number1       => 'US1001',
            :l_qty1          => '1',
            :l_amt1          => '150.00'  
        }
        # Need to determine how this can use the test API credentials and not production when we go live
        #@transaction = @caller.call(req)
        #puts @transaction.response
        #assert_equal 'Success', @transaction.response["ACK"].to_s 
    end

end

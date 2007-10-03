# The module has a class which holds merchant and PayPal endpoint information. 
# It has a method which can me mixed in to convert a hash to a string in CGI format.
module PayPalSDKProfiles 
  # Method to convert a hash to a string of name and values delimited by '&' as name1=value1&name2=value2...&namen=valuen.
  def hash2cgiString(h)
    h.map { |a| a.join('=') }.join('&') 
  end
# The class has the attributes which holds merchant credentials and client information needed for making the PayPal API call. 
  class Profile         
    cattr_accessor :credentials 
    cattr_accessor :endpoints 
    cattr_accessor :client_info 
    cattr_accessor :proxy_info 
    cattr_accessor :PAYPAL_EC_URL 
    cattr_accessor :DEV_CENTRAL_URL 
# Redirect URL for Express Checkout 
    @@PAYPAL_EC_URL="https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token="
#    
    @@DEV_CENTRAL_URL="https://developer.paypal.com"
###############################################################################################################################    
#    NOTE: Production code should NEVER expose API credentials in any way! They must be managed securely in your application.
#    To generate a Sandbox API Certificate, follow these steps: https://www.paypal.com/IntegrationCenter/ic_certificate.html
###############################################################################################################################
# specify the 3-token values.    
    @@credentials = {"USER" => "dennis_api1.ublip.com", "PWD" => "AX3XE7BA2LTFP5LY", "SIGNATURE" => "A1sZp.DlVATlq3OH5QXy-TDI.cXgAJHMhSqt7qXVeBGRKQ71aKSMySDO"}
    #@@credentials_sandbox =  {"USER" => "dennis_1187151313_biz_api1.ublip.com", "PWD" => "HDYNJVRNJBVGB2NB", "SIGNATURE" => "AoRDQnBgH.KEqOID7sp.JWkQJVQ.AMsC0nXQPb7Cwm2Zov9Jmm6Djpn3"}
# endpoint of PayPal server against which call will be made.
    @@endpoints = {"SERVER" => "api.paypal.com", "SERVICE" => "/nvp/"}
    #@@endpoints_sandbox = {"SERVER" => "api.sandbox.paypal.com", "SERVICE" => "/nvp/"}
# Proxy information of the client environment.    
    @@proxy_info = {"USE_PROXY" => false, "ADDRESS" => nil, "PORT" => nil, "USER" => nil, "PASSWORD" => nil }
# Information needed for tracking purposes.    
    @@client_info = { "VERSION" => "3.0", "SOURCE" => "PayPalRubySDKV1.2.0"}       
  end    
end
class GadgetController < ApplicationController
  
  layout nil
  
  def all
   @subdomain = request.host.split('.')[0]
  end
end

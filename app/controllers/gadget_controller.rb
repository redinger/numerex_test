class GadgetController < ApplicationController
  
  before_filter :authorize
  layout nil
  def all
    @account = Account.find(session[:account_id])
  end
end

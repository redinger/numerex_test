class ContactController < ApplicationController

def index
end

# Send feedback to support@ublip.com
def thanks
  Notifier.deliver_app_feedback(session[:email], request.subdomains.first, params[:feedback])
end

end

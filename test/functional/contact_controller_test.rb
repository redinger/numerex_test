require File.dirname(__FILE__) + '/../test_helper'
require 'contact_controller'

# Re-raise errors caught by the controller.
class ContactController; def rescue_action(e) raise e end; end

class ContactControllerTest < Test::Unit::TestCase
  
  fixtures :users
  
  module RequestExtensions
    def server_name
      "helo"
    end
    def path_info
      "adsf"
    end
    def subdomains
      ["myfleet"]
    end
  end
  
  def setup
    @controller = ContactController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.extend(RequestExtensions)
  end

  def test_submit
    post :thanks, {:feedback => "testing feedback form"}, {:user => users(:dennis), :email => "dennis@ublip.com"}
    assert_response :success
  end
end

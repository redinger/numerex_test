class HomeController < ApplicationController

  def index
    @devices = Device.find(:all)
  end
end

class Admin::DeviceProfilesController < ApplicationController
  before_filter :authorize_super_admin
  layout 'admin'
  
  helper_method :encode_profile_options
  
  def encode_profile_options(profile)
    (profile.speeds ? "F" : "-") + (profile.stops ? "S" : "-") + (profile.idles ? "I" : "-") + (profile.runs ? "R" : "-") + (profile.watch_gpio1 ? "1" : "-") + (profile.watch_gpio2 ? "2" : "-")
  end
  
  def index
    @profiles = DeviceProfile.find(:all)
  end

  def show
    @profile = DeviceProfile.find(params[:id])
  end

  def new
    @profile = DeviceProfile.new
  end

  def edit
    @profile = DeviceProfile.find(params[:id])
  end

  def create
    if request.post?
      profile = DeviceProfile.new(params[:profile])
      apply_options_to_profile(params,profile)
      
      gpio1_success = apply_gpio_options(profile,params[:gpio1],:watch_gpio1,:gpio1_labels)
      gpio2_success = apply_gpio_options(profile,params[:gpio2],:watch_gpio2,:gpio2_labels)
      
      if gpio1_success and gpio2_success and profile.save
        flash[:success] = "#{profile.name} created successfully"
        redirect_to :action => 'index' and return
      else
        error_msg = ''
        
        profile.errors.each{ |field, msg|
          error_msg += msg + '<br />'
        }
        
        flash[:error] = error_msg
        redirect_to :action => 'new' and return
      end
    end
  end

  def update
    if request.post?
      profile = DeviceProfile.find(params[:id])
      profile.update_attributes(params[:profile])
      apply_options_to_profile(params,profile)
      
      gpio1_success = apply_gpio_options(profile,params[:gpio1],:watch_gpio1,:gpio1_labels)
      gpio2_success = apply_gpio_options(profile,params[:gpio2],:watch_gpio2,:gpio2_labels)
      
      if gpio1_success and gpio2_success and profile.save
        flash[:success] = "#{profile.name} updated successfully"
        redirect_to :action => 'index' and return
      else
        error_msg = ''
        
        profile.errors.each{ |field, msg|
          error_msg += msg + '<br />'
        }
        
        flash[:error] = error_msg
        redirect_to :action => 'edit', :id => profile.id and return
      end
    end
  end

  def destroy
    if request.post?
      profile = DeviceProfile.find(params[:id])
      if profile.devices.any?
        flash[:error] = "Device profile still in use"
      else
        profile.destroy
        flash[:success] = "#{profile.name} deleted successfully"
      end
    end
    redirect_to :action => 'index'
  end
  
private
  def apply_options_to_profile(params,profile)
    update_attributes_with_checkboxes(profile,[:speeds,:stops,:idles,:runs],params[:options])
  end
  
  def apply_gpio_options(profile,options,watch,labels)
    profile.update_gpio_attributes(watch,labels,options[:name],options[:low_value],options[:high_value],options[:low_notice],options[:high_notice])
  end
end

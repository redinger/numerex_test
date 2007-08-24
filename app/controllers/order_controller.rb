class OrderController < ApplicationController
  def index
   render :action => 'step1'
  end
  
  def step1
    
  end
  
  def step2
    
  end
  
  def complete
    render_text 'done'
  end
end

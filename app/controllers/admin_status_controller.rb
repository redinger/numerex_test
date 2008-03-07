class AdminStatusController < ApplicationController
  session :off, :only => %w(up_check)

  def up_check
   retval = ActiveRecord::Base.connection.execute('select * from schema_info limit 1')
   render(:text => "Site ok @ #{Time::now}, Schema #: #{retval.fetch_row}") && return
  end
end

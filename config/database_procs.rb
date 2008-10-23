require "rubygems"
require "dm_client.rb"

task :setup_db_procs do
  begin
    sudo "chmod a+x #{current_path}/*.sh"
  rescue
  end
  sudo "mkdir -p /var/run/ublip_db"
  sudo "chown ublip:ublip /var/run/ublip_db"
  begin
    continue = true
    run "cd #{current_path} && rake ublip:setup_db_scripts RAILS_ENV=#{rails_env}"
  rescue
    puts "Unable to run setup db scripts rake task"
    continue = false
  end
  if continue
    if DeployManagerClient.get_db_admin(customer_name)
      run "cd #{current_path} && rake ublip:deploy_db_procs RAILS_ENV=#{rails_env}"
    else
      puts "************************************************************************************************************"
      puts "Insufficent access to deploy db procs on this system, make sure this gets done!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      puts "*************************************************************************************************************"
    end
    
    begin  
      sudo "crontab -u #{user} -l" do |channel, stream, data|
        if !data.include?('no crontab for') #only get current contents if there is a crontab
          sudo "crontab -u #{user} -l | grep -v 'stopreport.sh' > oldcrontab"
        end
      end
    rescue
    end
    
    sudo "echo '* * * * * #{current_path}/stopreport.sh >> #{current_path}/log/stopreport.log 2>&1' >> oldcrontab"
    sudo "crontab -u #{user} oldcrontab"
    sudo "rm oldcrontab"
    
    begin  
      sudo "crontab -u #{user} -l" do |channel, stream, data|
        if !data.include?('no crontab for') #only get current contents if there is a crontab
          sudo "crontab -u #{user} -l | grep -v 'idlereport.sh' > oldcrontab"
        end
      end
    rescue
    end
    
    sudo "echo '* * * * * #{current_path}/idlereport.sh >> #{current_path}/log/idlereport.log 2>&1' >> oldcrontab"
    sudo "crontab -u #{user} oldcrontab"
    sudo "rm oldcrontab"  
    
    begin  
      sudo "crontab -u #{user} -l" do |channel, stream, data|
        if !data.include?('no crontab for') #only get current contents if there is a crontab
          sudo "crontab -u #{user} -l | grep -v 'runtimereport.sh' > oldcrontab"
        end
      end
    rescue
    end
    
    sudo "echo '* * * * * #{current_path}/runtimereport.sh >> #{current_path}/log/runtimereport.log 2>&1' >> oldcrontab"
    sudo "crontab -u #{user} oldcrontab"
    sudo "rm oldcrontab"
  end
end
task :setup_db_procs do
  sudo "chmod a+x #{current_path}/stopreport.sh"
  sudo "mkdir -p /var/run/ublip_db"
  sudo "chown ublip:ublip /var/run/ublip_db"
  run "cd #{current_path} && rake setup_db_scripts RAILS_ENV=#{rails_env}"

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
  
end
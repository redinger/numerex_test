task :setup_db_procs do
  sudo "mkdir -p /var/run/ublip_db"
  sudo "chown ublip:ublip /var/run/ublip_db"
  run "cd #{current_path} && rake setup_db_scripts RAILS_ENV=#{rails_env}"
  run "crontab -u #{user} -l | grep -v 'stopreport.sh' > oldcrontab"
  run "echo '* * * * * #{current_path}/stopreport.sh >> #{current_path}/log/stopreport.log 2>&1' >> oldcrontab"
  run "crontab -u #{user} oldcrontab"
  run "rm oldcrontab"
end
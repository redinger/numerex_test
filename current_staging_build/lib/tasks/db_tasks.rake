namespace :ublip do
  
  desc 'Setup databse procs in cron'
  task :setup_db_scripts => :environment do 
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    process_script_file("stopreport.sh", db_config)
    process_script_file("idlereport.sh", db_config)
    process_script_file("runtimereport.sh", db_config)
    process_script_file("transientreport.sh", db_config)
  end
  
  desc 'Deploy database procedures and triggers'
  task :deploy_db_procs => :environment do
    execute_mysql_command("source #{RAILS_ROOT}/db_procs.sql")
    execute_mysql_command("source #{RAILS_ROOT}/geofence.sql")
  end
  
  def process_script_file(filename, db_config)
    scriptFile = File.new(filename)
    contents = scriptFile.read
    contents.gsub!('$USERNAME', db_config['username'])
    contents.gsub!('$PASSWORD', db_config['password'])
    contents.gsub!('$DBNAME', db_config['database'])
    
    if (db_config['host'].nil?) 
      contents.gsub!('-h $DBHOST', ' ')
    else
      contents.gsub!('$DBHOST', db_config['host'])
    end
    
    scriptFile.close
    scriptFile = File.new(filename, "w")
    scriptFile.write(contents)
  end
  
   def execute_mysql_command(command)
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    cmd = "mysql -u#{db_config['username']} #{db_config['host'].nil? ? " ":"-h#{db_config['host']}"} -p#{db_config['password']} --execute='#{command}'"
    puts cmd
    puts `#{cmd}`
  end
  
end

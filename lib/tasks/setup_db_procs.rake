desc 'Setup databse procs in cron'
task :setup_db_scripts => :environment do 
  db_config = ActiveRecord::Base.configurations[RAILS_ENV]
  scriptFile = File.new("stopreport.sh")
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
  scriptFile = File.new("stopreport.sh", "w")
  scriptFile.write(contents)
end
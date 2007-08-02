desc 'Exports data from MySQL and creates fixure'
task :extract_fixtures => :environment do 
  sql = "SELECT * FROM readings where event_type='startstop_et41' order by created_at desc limit 50" 
  skip_tables = ["schema_info"]
  table_name = 'readings'
  ActiveRecord::Base.establish_connection 
    #(ActiveRecord::Base.connection.tables - skip_tables).each do |table_name| 
      i = "000" 
      File.open("#{RAILS_ROOT}/test/fixtures/readings_new.yml", 'w') do |file| 
      data = ActiveRecord::Base.connection.select_all(sql % table_name) 
      file.write data.inject({}) { |hash, record| 
        hash["#{table_name}_#{i.succ!}"] = record 
        hash 
      }.to_yaml 
     #end
  end 
end
require "rubygems"

# This statement exists so that our servers don't need the dmclient gem installed
begin
  require "dm_client.rb"
rescue Exception => e
  puts "Doing nothing since the dmclient gem isn't installed"
end


namespace :ublip do
  
  desc 'Tag build in SVN for deployment to staging'
  task :tag_for_staging do
    customer = ENV['customer']
    svn_base = customer.nil? ? get_svn_base : DeployManagerClient.get_repo(customer)
    staging_url = svn_base + "/tags/current_staging_build"
    execute_cmd("svn delete #{staging_url} -m 'removing previous staging build'")
    cmd = "svn copy #{svn_base}/tags/successful_build_#{get_revision_datetime(ENV['revision'])} #{staging_url} -m 'moving build to staging'"
    execute_cmd(cmd)
  end
  
  desc 'Tag staging build in SVN for deployment to production'
  task :tag_for_prod do
    customer = ENV['customer']
    svn_base = customer.nil? ? get_svn_base : DeployManagerClient.get_repo(customer)
    prod_url = "#{svn_base}/tags/current_production_build"
    execute_cmd("svn delete #{prod_url} -m 'removing previous production build'")
    cmd = "svn copy #{svn_base}/tags/current_staging_build #{prod_url} -m 'moving staging build to prod'"
    execute_cmd(cmd)
  end
end

def execute_cmd(cmd)
  puts cmd
  puts `#{cmd}`
end

def get_revision_datetime(rev)
  customer = ENV['customer']
  if customer.nil?
    svn_info = `svn info -r#{rev}`
  else
    svn_info = `svn info -r#{rev} #{DeployManagerClient.get_repo(customer)}`
  end
  svn_info.each_line do |line|
    if (line.include?("Last Changed Date:")) 
      line.slice!("Last Changed Date:")
      line.slice!(/\(.*\)/)
      datetime = line[0, line.rindex(/[+-]/)]
      datetime.delete!(" :-")
      return datetime.strip
    end
  end
end

def get_svn_base
  repo_url = get_repo_url
  last_slash = repo_url.rindex('/')
  repo_url[0, last_slash]
end

def get_repo_url
  svn_info = `svn info`
  svn_info.each_line do |line|
    if (line.include?("URL:")) 
      line.slice!("URL:")
      return line.strip!
    end
  end
end
require "rubygems"
require "dm_client.rb"

namespace :ublip do
  
  desc 'Tag build in SVN for deployment to staging'
  task :tag_for_staging do
    customer = ENV['customer']
    svn_base = customer.nil? ? get_svn_base : DeployManagerClient.get_repo(customer)
    staging_url = svn_base + "/tags/current_staging_build"
    execute_cmd("svn delete #{staging_url} -m \"removing previous staging build\"")
    cmd = "svn copy #{svn_base}/tags/successful_build_#{get_revision_datetime(ENV['revision'])} #{staging_url} -m \"moving build to staging\""
    execute_cmd(cmd)
  end
  
  desc 'Tag staging build in SVN for deployment to production'
  task :tag_for_prod do
    customer = ENV['customer']
    svn_base = customer.nil? ? get_svn_base : DeployManagerClient.get_repo(customer)
    prod_url = "#{svn_base}/tags/current_production_build"
    execute_cmd("svn delete #{prod_url} -m 'removing previous production build'")
    cmd = "svn copy #{svn_base}/tags/current_staging_build #{prod_url} -m \"moving staging build to prod\""
    execute_cmd(cmd)
  end
  
  desc 'Create a new customer branch'
  task :create_new_branch do
    branch_name = ENV['branch_name']
    svn_base = DeployManagerClient.get_repo("SharedFleet")
    check = execute_cmd("svn info #{svn_base}/branches/#{branch_name}")
    if(check.length==0)
      execute_cmd("svn mkdir https://ublip.svn.ey01.engineyard.com/Ublip_v2/branches/#{branch_name} -m \"creating new customer branch\"")
      execute_cmd("svn mkdir https://ublip.svn.ey01.engineyard.com/Ublip_v2/branches/#{branch_name}/tags -m 'creating new customer branch'")
      execute_cmd("svn copy #{svn_base}/tags/current_production_build #{svn_base}/branches/#{branch_name}/trunk -m 'creating new customer branch'")
      execute_cmd("svn copy #{svn_base}/tags/current_production_build #{svn_base}/branches/#{branch_name}/tags/current_production_build -m 'creating new customer branch'")
    else
      puts "Branch Already Exists!"
    end
  end
  
  desc 'Update customer branch to latest from trunk'
  task :update_branch do
     customer = ENV['customer']
     svn_base = DeployManagerClient.get_repo("SharedFleet")
     cust_svn_base = DeployManagerClient.get_repo(customer)
     prod_url = "#{cust_svn_base}/tags/current_production_build"
     cust_trunk = "#{cust_svn_base}/trunk"
     execute_cmd("svn delete #{prod_url} -m 'removing previous production build'")
     execute_cmd("svn delete #{cust_trunk} -m 'removing previous production build'")
     execute_cmd("svn copy #{svn_base}/tags/current_production_build #{cust_trunk} -m \"updating branch to latest prod build from trunk\"")
     execute_cmd("svn copy #{svn_base}/tags/current_production_build #{prod_url} -m \"updating branch to latest prod build from trunk\"")
  end
  
end

def execute_cmd(cmd)
  puts cmd
  output = `#{cmd}`
  puts output
  return output
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
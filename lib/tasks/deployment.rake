namespace :ublip do
  
  desc 'Tag build in SVN for deployment to staging'
  task :tag_for_staging do
    staging_url = "#{get_svn_base}/tags/current_staging_build -m 'removing previous staging build'"
    execute_cmd("svn delete #{staging_url}")
    cmd = "svn copy #{get_svn_base}/tags/successful_build_#{get_revision_datetime(ENV['revision'])} #{staging_url}"
    execute_cmd(cmd)
  end
  
  desc 'Tag staging build in SVN for deployment to production'
  task :tag_for_prod do
    prod_url = "#{get_svn_base}/tags/current_production_build -m 'removing previous production build'"
    execute_cmd("svn delete #{prod_url}")
    cmd = "svn copy #{get_svn_base}/tags/current_staging_build #{prod_url}"
    execute_cmd(cmd)
  end
end

def execute_cmd(cmd)
  puts cmd
  puts `#{cmd}`
end

def get_revision_datetime(rev)
  svn_info = `svn info -r#{rev}`
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
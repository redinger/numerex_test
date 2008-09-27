desc 'Continuous build target'
task :cruise do
  out = ENV['CC_BUILD_ARTIFACTS']
  mkdir_p out unless File.directory? out if out
  
  RAILS_ENV = ENV['RAILS_ENV'] = 'test'
  Rake::Task["environment"].invoke
  Rake::Task["db:test:purge"].invoke
  CruiseControl::reconnect
  Rake::Task["db:migrate"].invoke
  
  ENV['SHOW_ONLY'] = 'models,lib,helpers'
  Rake::Task["test:units:rcov"].invoke
  mv 'coverage/units', "#{out}/unit test coverage" if out
  
  ENV['SHOW_ONLY'] = 'controllers'
  Rake::Task["test:functionals:rcov"].invoke
  mv 'coverage/functionals', "#{out}/functional test coverage" if out
  
  # Commenting until we have integration tests...
  # Rake::Task["test:integration"].invoke
  begin
    copy_to_success_tag(ENV['CC_BUILD_REVISION'])
  rescue Exception => e
    puts "unable to tag in SVN"
    puts $!
    puts e.backtrace[1..-1] 
  end
  
end

def copy_to_success_tag(rev)
  puts "tagging revision #{rev} as successful build in SVN"
  dst = get_svn_base + "/tags/successful_build_" + get_revision_datetime
  cmd = "svn copy -r #{rev} #{get_repo_url} #{dst} -m 'successful build'"
  puts cmd
  puts `#{cmd}`
end

def get_svn_base
  repo_url = get_repo_url
  puts repo_url
  last_slash = repo_url.rindex('/')
  repo_url[0, last_slash]
end

def get_revision_datetime
  svn_info = `svn info`
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

def get_repo_url
  svn_info = `svn info`
  puts svn_info
  svn_info.each_line do |line|
    if (line.include?("URL:")) 
      line.slice!("URL:")
      return line.strip!
    end
  end
end

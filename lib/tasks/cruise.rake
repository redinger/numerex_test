desc 'Continuous build target'
task :cruise do
  puts `svn info`
  puts "revision #{ENV['CC_BUILD_REVISION']}"
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
  
  copy_to_success_tag(ENV['CC_BUILD_REVISION'])
  
end
  
  def copy_to_success_tag(rev)
    dst = get_svn_base + "/tags/successful_build_" + Time.now().strftime("%Y%m%d%H%M%S")
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
  
  def get_repo_url
    svn_info = `svn info`
    svn_info.each_line do |line|
      if (line.include?("URL:")) 
        line.slice!("URL:")
        return line.strip!
      end
    end
  end

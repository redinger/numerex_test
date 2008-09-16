desc 'Continuous build target'
task :cruise do
  puts "revision #{ENV['CC_BUILD_REVISION']}"
  pus ENV
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
  
end

desc 'temporary testing task...'
task :svn_test do
  copy_branch(1619, "https://ublip.svn.ey01.engineyard.com/Ublip_v2/trunk", "https://ublip.svn.ey01.engineyard.com/Ublip_v2/tags/successful_builds", "qwerty")
end

def copy_branch(rev, src, dst, comment)
  cmd = "svn copy -r #{rev} #{src} #{dst} -m #{comment}"
  puts cmd
  puts `#{cmd}`
end


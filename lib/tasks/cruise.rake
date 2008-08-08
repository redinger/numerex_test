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
#  Commenting out until rcov stops segfaulting
#  Rake::Task["test:units:rcov"].invoke
#  mv 'coverage/units', "#{out}/unit test coverage" if out
  Rake::Task["test:units"].invoke

  ENV['SHOW_ONLY'] = 'controllers'
#  Commenting out until rcov stops segfaulting
#  Rake::Task["test:functionals:rcov"].invoke
#  mv 'coverage/functionals', "#{out}/functional test coverage" if out
  Rake::Task["test:functionals"].invoke

  # Commenting until we have integration tests...
  # Rake::Task["test:integration"].invoke

  
  
end


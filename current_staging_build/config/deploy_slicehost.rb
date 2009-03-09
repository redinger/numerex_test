require 'mongrel_cluster/recipes'

#set :application, "eog.ublip.com"
set :application, "enfora.ublip.com"
set :repository,  "https://ublip.svn.ey01.engineyard.com/Ublip_v2/trunk"
set :scm_username,  "deploy"
set :scm_password,  "wucr5ch8v0"
set :user,        "ublip"
#set :password,    "p5uKUdre" # eog
set :password, "testing"
set :deploy_to,     "/opt/ublip/rails"
set :rails_env, "slicehost"
set :svn, "/usr/bin/svn"
set :sudo, "/usr/bin/sudo"
after "deploy:update_code", "symlink_configs"
#before "deploy", "daemons:stop"
#after "deploy", "daemons:start"
after "deploy", "setup_db_procs"
after "deploy:migrations", "setup_db_procs"

ssh_options[:paranoid] = false

role :web, application
role :app, application
role :db, application, :primary => true
role :db, application

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

namespace :deploy do
  task :restart, :roles => :app do
    run "cd /opt/ublip/rails/current; mongrel_rails cluster::restart;"
  end
end

task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
   run <<-CMD
     cd #{release_path} &&
     ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
     ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml &&
     ln -nfs #{shared_path}/config/enfora_gateway.yml #{release_path}/config/enfora_gateway.yml
   CMD
 end

require "bundler/capistrano"
require "rvm/capistrano"

set :application, "OpeningDesign"
set :repository, "git@github.com:OpeningDesign/OpeningDesign.git"

set :user, 'odr'
set :runner, 'odr'
set :use_sudo, false
set :scm, :git
set :branch, "master"
set :git_shallow_clone, 1
set :deploy_to, "/home/odr/deploy"

set :rvm_ruby_string, 'ruby-1.9.3-p194@odr_production'

role :web, "staging.openingdesign.com"                          # Your HTTP server, Apache/etc
role :app, "staging.openingdesign.com"                          # This may be the same as your `Web` server
role :db,  "staging.openingdesign.com", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :stalk do
  desc "Start stalker process (beanstalk consumer for async processing)"
  cmd = "here we should DRY up the repetitive part of the command... " # TODO
  task :start, :roles => :app do
    run "echo 'script/worker start currently DISABLED'"
    # run "cd #{current_path}; RAILS_ENV=production bundle exec script/worker start"
  end
  task :stop, :roles => :app do
    run "echo 'script/worker stop currently DISABLED'"
    # run "cd #{current_path}; RAILS_ENV=production bundle exec script/worker stop"
  end
  task :restart, :roles => :app do
    run "echo 'script/worker restart currently DISABLED'"
    # run "cd #{current_path}; RAILS_ENV=production bundle exec script/worker restart"
  end
end
after "deploy:start", "stalk:start"
after "deploy:stop", "stalk:stop"
after "deploy:restart", "stalk:restart"

after "deploy:update" do
  # could do something here
end

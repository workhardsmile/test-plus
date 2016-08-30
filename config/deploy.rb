require "bundler/capistrano"
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"

set :rvm_ruby_string, 'ruby-1.9.2-p180@rails31' 
set :rvm_type, :user 
set :user, "active"  # The server's user for deploys
set :password, "@Ctive123"
set :use_sudo, true

set :ssh_options, {:forward_agent => true}  # If you’re using your own private keys for git you might want to tell Capistrano to use agent forwarding with this command.
ssh_options[:keys] = %w(~/.ssh/id_rsa)

default_run_options[:pty] = true  # Must be set for the password prompt from git to work
set :scm, "git" # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
#set :scm_passphrase, "p@ssw0rd"  # The deploy user's password

set :application, "testplus-web-main"
set :repository,  "git@10.109.2.114:testplus_reload.git"
set :branch, "master"
set :migrate_target,  :current
set :rails_env, "development"
set :deploy_via, :remote_cache  # Remote caching will keep a local git repo on the server you’re deploying to and simply run a fetch from that rather than an entire clone. It will only fetch the changes since the last.
set :deploy_to, "/home/active/testplus_deploy"
set :bundle_gemfile,  "testplus-web-main/Gemfile"
# set :bundle_dir, File.join(fetch(:shared_path), "cached-copy", "testplus-web-main")
set :bundle_dir, File.join(fetch(:current_path), "testplus-web-main")
set :normalize_asset_timestamps, false

role :dev, "10.109.2.114"
#role :web, "localhost"                          # Your HTTP server, Apache/etc
#role :app, "localhost"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

#server "localhost", :app, :web, :db, :primary => true

set(:latest_release)  { fetch(:current_path, "testplus-web-main") }
set(:release_path)    { fetch(:current_path, "testplus-web-main") }
set(:current_release) { fetch(:current_path, "testplus-web-main") }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

default_environment["RAILS_ENV"] = 'development'
# default_environment["PATH"]         = "--"
# default_environment["GEM_HOME"]     = "--"
# default_environment["GEM_PATH"]     = "--"
# default_environment["RUBY_VERSION"] = "ruby-1.9.2-p180"

# default_run_options[:shell] = 'bash'


def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

def run_rake(cmd)
  run "cd #{current_path}/testplus-web-main; bundle exec #{cmd}"
end

namespace :db do
  task :create do
    run_rake("db:create")
  end
  
  task :migrate do
    run_rake("db:migrate")
  end
end

namespace :dash do
  task :init_data do
    run_rake("db:init_data")
  end
  
  task :import_all_cases do
    run_rake("db:import_all_cases")
  end
end

namespace :deploy do
  desc "Deploy your application"
  task :default do
    update
    restart
  end
  
  desc "Setup your git-based deployment app"
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "git clone #{repository} #{current_path}"
  end
  
  task :update do
    transaction do
      update_code
    end
    restart
  end
  
  task :cold do
    update
    bundle
    db.migrate
  end
  
  task :bundle do
    run "cd #{current_path}/testplus-web-main; bundle install"
  end
  
  task :start do
    run "sudo /opt/nginx/sbin/nginx"
  end
  
  task :restart do
    unless remote_file_exists?("#{current_path}/testplus-web-main/tmp")
      run "mkdir #{current_path}/testplus-web-main/tmp"
    end
    run "cd #{current_path}/testplus-web-main/tmp; rm restart.txt; touch restart.txt"
  end
  
  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}; git pull"
    
    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = fetch(:public_children, %w(images stylesheets javascripts)).map { |p| "#{latest_release}/testplus-web-main/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end
  
  desc "Update the database (overwritten to avoid symlink)"
  task :migrations do
    transaction do
      update_code
    end
    bundle
    db.migrate
    restart
  end
  
end

task :refresh_server do
  db.create
  db.migrate
  dash.init_data
  deploy.cold
  deploy.restart
end

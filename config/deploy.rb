# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'rzrtools'
set :repo_url, 'git@bitbucket.org:LittlePhish/rzr-tools.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :scm, :git
set :branch, "master"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/rzrtools/app'

# '/usr/local/rbenv'
#set :rbenv_ruby, '2.2.3'
#set :rbenv_type, :system # or :system, depends on your rbenv setup


#ssh_options[:forward_agent] = true


# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, false
set :ssh_options, {
  forward_agent: true
}

set :default_environment, {
  'PATH' => "$PATH:$HOME/.gem/bin"
}

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
# deploy.rb
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
#set :linked_files, fetch(:linked_files, []).push( 'config/secrets.yml')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :workers, { "statused,high" => 2, "high,medium" => 1, "low" => 1 }

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  desc 'Runs rake db:migrate if migrations are set'
  task :migrate => [:set_rails_env] do
    on primary fetch(:migration_role) do
      conditionally_migrate = fetch(:conditionally_migrate)
      info '[deploy:migrate] Checking changes in /db/migrate' if conditionally_migrate
      if conditionally_migrate && test("diff -q #{release_path}/db/migrate #{current_path}/db/migrate")
        info '[deploy:migrate] Skip `deploy:migrate` (nothing changed in db/migrate)'
      else
        info '[deploy:migrate] Run `rake db:migrate`'
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, "db:autoupgrade"
          end
        end
      end
    end
  end

  # task :seed_db, :roles => [:db] do
  #   env = fetch(:rails_env)
  #   run "cd #{release_path} && bundle exec rails runner -e #{env} db/seeds.rb" if env != "production"
  # end

  after 'deploy:updated', 'deploy:migrate'


end

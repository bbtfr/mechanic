# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'mechanic'
set :repo_url, 'https://github.com/bbtfr/mechanic.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/mechanic'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_files, %w{.env}

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system db/backups}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'tmp:clear'
      # end
    end
  end

end

desc "tail log file"
task :logs do
  on roles(:app) do
    execute "tail -f #{shared_path}/log/#{fetch(:rails_env)}.log"
  end
end

namespace :sidekiq do
  desc "tail log file"
  task :logs do
    on roles(:app) do
      execute "tail -f -n 200 #{shared_path}/log/sidekiq.log"
    end
  end
end

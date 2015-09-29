# config valid only for current version of Capistrano
lock '3.4.0'
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/configuration.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 
  'vendor/bundle', 'public/system', 'public/themes', 'plugins','files')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      within release_path do
        execute :rake, 'emoji'
      end
    end
  end

  desc "Upload yml file."
  task :upload_yml do
    on roles(:app) do
      execute "mkdir -p #{shared_path}/config"
      upload! StringIO.new(File.read("config/secrets.yml")), "#{shared_path}/config/secrets.yml"
      upload! StringIO.new(File.read("config/database.yml.example")), "#{shared_path}/config/database.yml"
      upload! StringIO.new(File.read("config/configuration.yml.example")), "#{shared_path}/config/configuration.yml"
    end
  end

end

namespace :redmine do
  task :plugins_migrate, :param do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "production" do
          execute :rake, "redmine:plugins:migrate"
        end
      end
    end
  end

  task :seed do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "production" do
          execute :rake, "REDMINE_LANG=en redmine:load_default_data"
        end
      end
    end
  end
end

# after "deploy:updating", "redmine:plugins_migrate"
# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'template_api'
set :repo_url, 'git@github.com:Instamotor-Labs/template-api.git'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/deploy/template_api'

set :forward_agent, true

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml .env}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log pids tmp/cache sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :rbenv_ruby, '2.2.1'

# Default value for keep_releases is 5
# set :keep_releases, 5

Dir["#{File.dirname(__FILE__)}/deploy/recipes/*"].each { |plugin| load plugin }


task :notify_rollbar do
  on roles(:app) do |h|
    revision   = `git log -n 1 --pretty=format:"%H"`
    local_user = `whoami`
    rollbar_token = '6818240355ff4a1183ee689acf40444b'
    rails_env  = fetch(:rails_env, 'production')
    execute "curl https://api.rollbar.com/api/1/deploy/ -F access_token=#{rollbar_token} -F environment=#{rails_env} -F revision=#{revision} -F local_username=#{local_user} >/dev/null 2>&1", :once => true
  end
end
after :deploy, 'notify_rollbar'

after 'deploy:publishing', 'nginx:install'
after 'deploy:publishing', 'nginx:configure'
after 'deploy:publishing', 'nginx:reload'

%w[api api_integr worker].each do |role|
  after 'deploy:publishing', "foreman:#{role}:export"
  after 'deploy:publishing', "foreman:#{role}:restart"
end

set :slack_token, 'pQF9qWcaN8k1R0mkIGQl999E'
set :slack_channel, '#devops'
set :slack_team, 'instamotor'
set :slack_icon_emoji, ':rocket:'

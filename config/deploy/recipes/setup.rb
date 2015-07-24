def from_template(file)
  require 'erb'
  template = File.read(File.join(File.dirname(__FILE__), '../../..', file))
  ERB.new(template).result(binding)
end

namespace :nginx do
  task :install do
    on roles(:api, :app) do
      execute 'sudo apt-get install nginx -y'
    end
  end

  task :reload do
    on roles(:api, :app) do
      execute 'sudo service nginx reload'
    end
  end

  task :configure do
    on roles(:api, :app) do
      # https://github.com/capistrano/sshkit/blob/master/EXAMPLES.md#upload-a-file-from-a-stream
      nginx_config_content = StringIO.new(from_template('config/deploy/server/nginx.conf.erb'))
      nginx_config_path = "#{shared_path}/nginx.#{fetch(:domain)}.conf"
      upload! nginx_config_content, "#{nginx_config_path}"
      execute "sudo ln -sf #{nginx_config_path} /etc/nginx/sites-enabled/#{fetch(:stage)}_apiserver.conf"
    end
  end
end

namespace :foreman do
  [
    {service: :api, roles: [:api]},
    {service: :api_integr, roles: [:api_integr]},
    {service: :worker, roles: [:worker]}
  ].each do |service|
    namespace service_name = service[:service] do
      procfile = "Procfile.#{service[:service]}"
      desc "Export the #{procfile} to Ubuntu's upstart scripts"
      task :export do
        on roles(*service[:roles]) do

          # Using custom upstart templates to allow sidekiq gracefully shut down
          # @see https://intercityup.com/blog/allowing-long-running-sidekiq-jobs-finish-deploying.html
          # @see config/sidekiq.yml
          # @see https://github.com/ddollar/foreman/tree/master/data/export/upstart
          # NOTE: --template expects directory with 3 config templates

          cmd = ["cd #{release_path} &&",
                 "sudo bundle exec foreman export -a #{service_name}",
                 "-u deploy upstart /etc/init ",
                 "-e .env -f #{procfile}",
                 "--template=config/deploy/foreman_templates"]

          execute cmd.join(' ')
        end
      end

      desc "Start the #{service_name} service"
      task :start do
        on roles(*service[:roles]) do
          execute "sudo start #{service_name}"
        end
      end

      desc "Stop the #{service_name} service"
      task :stop do
        on roles(*service[:roles]) do
          execute "sudo stop #{service_name}"
        end
      end

      desc "Restart the #{service_name} service"
      task :restart do
        on roles(*service[:roles]), in: :sequence, wait: 40 do
          execute "sudo start #{service_name} || sudo restart #{service_name}"
        end
      end
    end
  end
end

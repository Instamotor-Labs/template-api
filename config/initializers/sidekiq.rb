# NOTE: Use :key: syntax in config/sidekiq.yml to import them as symbols
sidekiq_config       = YAML.load_file("#{Rails.root}/config/sidekiq.yml")

# TODO: File logging is a temp solution?
Sidekiq.logger       = Logger.new("#{Rails.root}/log/sidekiq.log")
# 10/Jul/2015: Let's keep this severity for a while to ensure everything working
Sidekiq.logger.level = Logger::Severity::INFO

# NOTE: We use scheduler, so if there's really need to retry jobs, set this option
# directly into job class: sidekiq_options {retry: num}
# @see https://github.com/mperham/sidekiq/wiki/Error-Handling#configuration
# TODO: Select jobs which MUST be retried in case of fail
Sidekiq.default_worker_options = { retry: false }

# Sidekiq namespace should be set here, not in YAML config (strange, but it's true):
# ERROR: namespace should be set in your ruby initializer, is ignored in config file
# config.redis = { :url => ..., :namespace => 'im_api_background_jobs' }

redis_url            = sidekiq_config[Rails.env.to_sym][:url]
sidekiq_config.update(namespace: 'im_background_jobs', url: redis_url)

Sidekiq.configure_server do |config|
  config.redis  = sidekiq_config

  # Configuring sidekiq-cron

  # Unicorn-related init method
  # @see https://github.com/ondrejbartas/sidekiq-cron#forking-processes
  schedule_file = "#{Rails.root}/config/sidekiq_schedule.yml"

  Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))

  # Configuring sidekiq-status

  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 60.minutes
  end

  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config

  # Configuring sidekiq-status

  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end

source 'https://rubygems.org'

ruby '2.2.1'

gem 'rails', '~> 4.2.3'
gem 'pg', '~> 0.18.2'
gem 'groupdate' # MC stats fetching


gem 'rack-cors', '~> 0.3.1'

gem 'grape', github: 'intridea/grape'
gem 'grape-rabl'
gem 'grape-swagger'
gem 'grape-kaminari'

gem 'protected_attributes'

gem 'rest-client'

gem 'foreman'

# BACKGROUND PROCESSING

gem 'sidekiq'
gem 'sidekiq-cron'
gem 'sidekiq-status'
gem 'sinatra', require: false

# ANALYZERS

gem 'rollbar', '~> 1.5.3'

group :production, :integration do
  gem 'unicorn', '~> 4.8.3'
  gem 'unicorn-worker-killer'
end

group :development do
  gem 'ruby-debug-ide', require: false
  gem 'debase', require: false
  gem 'thin'
  gem 'terminal-notifier', require: false
  gem 'ruby-graphviz', require: false
  gem 'better_errors'
  gem 'binding_of_caller', platforms: [:ruby_22]
  gem 'httplog'
  gem 'bullet'
end

group :development, :test do
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rails', '~> 1.1'
  gem 'slackistrano', require: false
  gem 'parallel_tests'
  gem 'airbrussh', require: false
  gem 'dotenv', require: false
end

group :test do
  gem 'rspec', '~> 3.1.0'
  gem 'rspec-rails', '~> 3.1'
  gem 'rspec-its'
  gem 'rack-test', require: 'rack/test'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'nokogiri' # used by custom have_xpath RSpec matcher
  gem 'webmock'
  gem 'test_after_commit'
  gem 'faker', github: 'Instamotor-Labs/faker'

  # CI & ANALYZERS
  gem 'ci_reporter', '~> 2.0.0', github: 'ci-reporter/ci_reporter'
  gem 'ci_reporter_rspec', '~> 1.0.0', github: 'ci-reporter/ci_reporter_rspec'
  gem 'metric_fu', require: false
  gem 'rubocop', require: false
  gem 'simplecov', '~> 0.8.2', require: false
  gem 'simplecov-rcov', require: false
end

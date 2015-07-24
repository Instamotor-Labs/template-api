require 'sidekiq/web'
require 'sidekiq/cron/web'
require 'sidekiq-status/web'

Rails.application.routes.draw do

  root to: redirect('/v1/health')

  if Rails.env.production? || Rails.env.integration?
    Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
      username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
    end
  end

  mount Sidekiq::Web => '/sidekiq'
  mount API => '/', via: [:head, :get, :put, :post, :delete]

end

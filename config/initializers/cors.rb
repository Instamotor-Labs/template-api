Rails.application.config.middleware.use Rack::Cors do
  allow do
    # TODO whitelist allowed origins
    origins '*'
    resource '*', headers: :any,
             methods: [:get, :post, :put, :delete, :options],
             expose:  %w[X-Total X-Total-Pages X-Page X-Per-Page X-Next-Page X-Prev-Page X-Offset]
  end
end
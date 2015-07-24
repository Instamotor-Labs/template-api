class API < Grape::API

  helpers do
    def logger
      Rails.logger
    end
  end

  use ::ApiVerboseLogger

  helpers ParamsHelper

  format :json

  default_format :json
  default_error_status 400

  rescue_from ActiveRecord::RecordNotFound do |e|
    error_response(status: 400, message: e.message)
  end

  mount ::IM::AppV1

  # Handling 404
  # It is very crucial to define this endpoint at the very end of your API, as it literally accepts every request.
  route :any, '*path' do
    request_data = {
      method: env['REQUEST_METHOD'],
      path: env['PATH_INFO'],
      query: env['QUERY_STRING']
    }
    logger.error "[api] Path not found: #{request_data}"
    error! 'Not Found', 404
  end
end

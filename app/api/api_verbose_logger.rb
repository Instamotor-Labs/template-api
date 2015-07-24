class ApiVerboseLogger < Grape::Middleware::Base
  HEADERS_BLACKLIST = ['HTTP_COOKIE'].freeze

  class Grape::Middleware::Error
    def call!(env)
      @env = env

      begin
        log_error_response do
          error_response(catch(:error) do
                           return @app.call(@env)
                         end)
        end
      rescue StandardError => e
        is_rescuable = rescuable?(e.class)
        if e.is_a?(Grape::Exceptions::Base) && !is_rescuable
          handler = lambda { |arg| error_response(arg) }
        else
          raise unless is_rescuable
          handler = find_handler(e.class)
        end

        handler.nil? ? handle_error(e) : exec_handler(e, &handler)
      end
    end

    def log_error_response(&block)
      start  = Time.now
      result = block.call
      stop   = Time.now

      milliseconds_taken ||= ((stop - start) * 1000).to_i

      response_status  = result[0]
      response_headers = result[1]
      response_headers = response_headers.select { |k, v| k.start_with?('HTTP_') && !ApiVerboseLogger::HEADERS_BLACKLIST.include?(k) }
        .collect { |pair| [pair[0].sub(/^HTTP_/, ''), pair[1]] }
        .collect { |pair| pair.join(': ') }
        .sort

      parts = []
      result[2].each { |part| parts << part }
      response_body = parts.join

      Rails.logger.debug "[api] Response headers: #{response_headers}"
      Rails.logger.debug "[api] Response body: #{response_body}"
      Rails.logger.info "[api] #{@env['REQUEST_METHOD']} \"#{@env['PATH_INFO']}\" Completed  #{response_status} in #{milliseconds_taken}ms"

      result
    end
  end

  def before
    @start = Time.now

    return if request_target.include?('health')
    Rails.logger.info
    Rails.logger.info "[api] Started #{request_method} \"#{request_target}\" for #{request_ip} at #{Time.now}"
    Rails.logger.debug "[api] Request headers: #{request_headers}"
    Rails.logger.debug "[api] Request body: #{request_params}"
    Rails.logger.debug "[api] Source: #{source_file}:#{source_line}"
  end

  def after
    @stop = Time.now

    return @app_response if request_target.include?('health')

    Rails.logger.debug "[api] Response headers: #{response_headers}"
    Rails.logger.debug "[api] Response body: #{response_body}"
    Rails.logger.info "[api] Completed #{request_method} \"#{request_target}\" code #{response_status} in #{milliseconds_taken}ms"

    @app_response
  end


  private

  def response_status
    @app_response[0]
  end

  def response_headers
    @app_response[1]
  end

  def response_body
    return 'Body too long' if @app_response[2].length > 100.kilobytes
    parts = []
    @app_response[2].each { |part| parts << part }
    parts.join
  end


  def milliseconds_taken
    @milliseconds_taken ||= ((@stop - @start) * 1000).to_i
  end

  def request_log_data
    @request_log_data ||= create_request_log_data
  end

  def request_method
    env['REQUEST_METHOD']
  end

  def request_target
    env['PATH_INFO']
  end

  def request_ip
    env['REMOTE_ADDR']
  end

  def request_headers
    headers = env.select { |k, v| k.start_with?('HTTP_') && !HEADERS_BLACKLIST.include?(k) }
      .collect { |pair| [pair[0].sub(/^HTTP_/, ''), pair[1]] }
      .collect { |pair| pair.join(': ') }
      .sort
  end

  def request_params
    return 'Request body too long' if env['rack.input'].size > 10.kilobytes
    request_params = env['rack.input'].read
    env['rack.input'].rewind
    request_params
  end

  def source_file
    env['api.endpoint'].source.source_location[0][(Rails.root.to_s.length+1)..-1]
  end

  def source_line
    env['api.endpoint'].source.source_location[1]
  end
end
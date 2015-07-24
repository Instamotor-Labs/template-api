module IM
  class AppV1 < Grape::API
    version 'v1', using: :path

    # Rabl views root folder
    use Rack::Config do |env|
      env['api.tilt.root'] = File.join(Dir.pwd, 'app/api/im/v1/views')
    end

    desc 'Returns server health status'
    get :health do
      { response: 'healthy' }
    end

    add_swagger_documentation(hide_format: true, api_version: 'v1')
  end
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require 'support/mocks'

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'factory_girl'
require 'webmock/rspec'
require 'rack/test'

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.maintain_test_schema!

# See .simplecov for current configuration (http://goo.gl/MJnFDF)
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rspec'
end

require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.configure do |config|

  config.include Rack::Test::Methods
  config.include FactoryGirl::Syntax::Methods

  config.mock_with :rspec
  config.expect_with :rspec

  module RSpec::Core::MemoizedHelpers::ClassMethods
    def fg_let(*args)
      args.each { |arg| let(arg) { create(arg) } }
    end

    def fg_let!(*args)
      args.each { |arg| let!(arg) { create(arg) } }
    end
  end

  I18n.enforce_available_locales = false
  # require 'support/db_config'
  require 'support/seeds'

  Rabl.configure do |conf|
    conf.include_json_root = false
    conf.include_child_root = false
  end

  def app
    API
  end

  def authenticated_headers(user_auth_token)
    { 'HTTP_USER_AGENT' => user_auth_token.name, 'HTTP_X-Instamotor-Auth-Token' => user_auth_token.auth_token }
  end

  def client_headers(client_id, client_type)
    { 'HTTP_X-Instamotor-Ios-Client-Id' => client_id, 'HTTP_X-Instamotor-Ios-Client-Version' => client_type }
  end


  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Do not use the truncation strategy in DatabaseCleaner, in your RSpec config.
  # This strategy seems to cause a bottleneck which will negate any gain made
  # through parallelization of your tests. If possible, use the transaction strategy
  # over the truncation strategy.
  #                       *Note: This issue does not seem to exist in relation to features, only to specs.

  config.alias_example_group_to :describe_model, type: :model

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end

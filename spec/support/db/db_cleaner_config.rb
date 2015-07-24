RSpec.configure do |config|
  require 'database_cleaner'

  # https://github.com/grosser/parallel_tests/issues/66

  # Do not use the truncation strategy in DatabaseCleaner, in your RSpec config.
  # This strategy seems to cause a bottleneck which will negate any gain made
  # through parallelization of your tests. If possible, use the transaction strategy
  # over the truncation strategy.
  #                       *Note: This issue does not seem to exist in relation to features, only to specs.

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:transaction)
    DatabaseCleaner[:active_record, connection: :harvester_test].strategy = :transaction
    DatabaseCleaner[:active_record, connection: :harvester_test].clean_with(:transaction)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

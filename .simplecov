require 'simplecov-rcov'
# Creating base simple 'profile', skip bundled 'rails' adapter
SimpleCov.profiles.define 'default' do
  use_merging false
  formatter SimpleCov::Formatter::RcovFormatter

  add_filter '/spec'
  add_filter '/lib'
end

SimpleCov.profiles.define 'rspec' do
  load_profile 'default'
  coverage_dir 'tmp/coverage/rspec'
end

SimpleCov.profiles.define 'cucumber' do
  load_profile 'default'
  coverage_dir 'tmp/coverage/cucumber'
end

SimpleCov.profiles.define 'minitest' do
  load_profile 'default'
  coverage_dir 'tmp/coverage/minitest'
end

puts 'Code coverage is on'
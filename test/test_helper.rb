require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] = 'test'
ENV['POSTGRESQL_TEST_URL'] = 'postgresql:///pvp?host=/var/run/postgresql'
require File.expand_path('../../config/environment', __FILE__)

require 'rails/test_help'

class ActiveSupport::TestCase
  self.use_transactional_tests = false
  self.use_instantiated_fixtures = false
end

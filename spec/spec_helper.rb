require 'bundler/setup'

require 'simplecov'
require 'active_record'
require 'database_cleaner'
require 'combustion'

SimpleCov.start do
  add_filter "spec/activerecord"
  add_filter "spec/support"
  add_filter "spec/internal"
end

Combustion.initialize! :active_record

require 'activerecord/view'

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.filter_gems_from_backtrace 'database_cleaner', 'activesupport'

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

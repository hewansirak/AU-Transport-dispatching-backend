ENV["RAILS_ENV"] = "test"

require "spec_helper"

require_relative "../config/environment"
abort("Rails is running production!") if Rails.env.production?
require "rspec/rails"
require "shoulda/matchers"
require "database_cleaner/active_record"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]
  config.use_transactional_fixtures = false   # DatabaseCleaner handles this
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include AuthHelpers, type: :request
  config.include FactoryBot::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
source "https://rubygems.org"

ruby ">= 3.2.2"

gem "rails", "~> 7.2.3"
gem "pg", "~> 1.5"
gem "puma", "~> 7.2"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

# Auth
gem "bcrypt", "~> 3.1"
gem "jwt", "~> 2.8"

# Authorization
gem "pundit", "~> 2.3"

# Serializers
gem "jsonapi-serializer", "~> 2.2"

# Background jobs (for email notifications)
gem "sidekiq", "~> 7.2"

# CORS (for your frontend)
gem "rack-cors", "~> 2.0"

# Pagination
gem "kaminari", "~> 1.2"

# Enum helper
# gem "active_record_extended", "~> 3.2"

group :development, :test do
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
  gem "dotenv-rails"
  gem "debug"
end

group :test do
  gem "shoulda-matchers", "~> 6.0"
  gem "database_cleaner-active_record", "~> 2.1"
end

group :development do
  gem "rubocop-rails", require: false
end
require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.load_defaults 7.2
    config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = true
    config.autoload_paths << Rails.root.join("app/lib")
    config.active_job.queue_adapter = :sidekiq
    config.time_zone = "Africa/Addis_Ababa"
    config.i18n.default_locale = :en

    config.hosts = nil if Rails.env.test?
  end
end
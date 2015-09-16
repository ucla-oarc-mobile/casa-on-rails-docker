Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_assets = true
  config.assets.digest = true
  config.assets.version = '1.0'
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false

  # Community App Sharing Architecture configuration
  config.casa = {
      :engine => {
          :uuid => 'b0c6aa29-9567-4f78-bcca-57794975806f'
      }
  }

  # Local configuration
  config.store = {
    :user_contact => { :name => "Joe Schmoe", :email => "joe@schmoecity.com" }
  }
end
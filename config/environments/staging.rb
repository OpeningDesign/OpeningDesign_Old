Odr::Application.configure do
  config.cache_classes = false
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = true

  # configure default url for host (requirement for devise mailers)
  config.action_mailer.default_url_options = { host: "#{SimpleConfig.subdomain}.#{SimpleConfig.domain}" }
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

end

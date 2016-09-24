img_prefix = 'app/assets/images/'
js_prefix    = 'app/assets/javascripts/'
style_prefix = 'app/assets/stylesheets/'
images = Dir["#{img_prefix}**/*.*"].map      { |x| x.gsub(img_prefix,    '') }
javascripts = Dir["#{js_prefix}**/*.*"].map      { |x| x.gsub(js_prefix,    '') }
css         = Dir["#{style_prefix}**/*.*"].map  { |x| x.gsub(style_prefix, '') }

TestPlusWebMain::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true
  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false
  # Generate digests for assets URLs
  config.assets.digest = true
  
  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new
  config.logger = Logger.new("#{Rails.root}/log/#{Rails.env}.log", 50, 100*1024*1024)

  # Use a different cache store in production
  config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )
  config.assets.precompile += css

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:'smtp.163.com',
    port:25,
    enable_starttls_auto:true,
    openssl_verify_mode:'none',
    domain: '163.com',
    user_name: 'demo_db@163.com',
    password: '163istuary'
  }

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify  
  Paperclip.options.merge!(:command_path => "/usr/bin")
end

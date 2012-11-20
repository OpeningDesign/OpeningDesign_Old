source 'http://rubygems.org'

gem 'rails', '3.2.6'
gem 'rubyzip'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'ffi', "1.0.9"
gem "high_voltage" #for static pages

group :test, :development do
  gem 'sqlite3'
  gem 'foreman'
end
group :staging, :production do
  gem 'pg'
  gem 'therubyracer'
  gem 'sendgrid'
end

gem 'devise'
gem 'omniauth-twitter'
gem 'omniauth-linkedin'
gem 'omniauth-facebook'
gem 'omniauth-openid'
gem 'recurly', '~> 2.1.5'
gem 'declarative_authorization'
gem 'ruby_parser'

gem 'social_connections', '0.0.19'
#gem 'social_connections', :path => "~/PrivateStuff/social_connections"

gem 'simple_form'
gem 'mailcatcher'

gem 'beanstalk-client'
gem 'stalker'
gem 'clockwork'
gem 'daemons'

gem 'hike'

gem 'ember-rails'

gem 'gravtastic'
gem 'acts_as_tree'
gem "paperclip", "~> 3.1.4"
gem "aws-sdk", '~> 1.3.4'
gem 'acts-as-taggable-on', "~> 2.2.2"
gem 'best_in_place'
gem 'block_helpers'
gem 'rails_admin', :git => 'git://github.com/sferik/rails_admin.git'
gem 'capistrano'
gem 'rvm-capistrano'
gem 'exception_notification', :require => 'exception_notifier'
group :production do
  gem 'passenger'
end

gem 'copycopter_client'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2"
  gem 'uglifier'
end

gem 'jquery-rails'

gem 'rails_simple_config', "0.0.1"

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test, :development do
  gem 'rspec-rails'
  gem 'launchy'
end

group :development do
  gem 'pry'
  gem 'pry-remote'
  gem 'pry-doc'
  gem 'eventmachine', '1.0.0.beta.2'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem "factory_girl_rails", :require => false
  gem "capybara", '1.0.1'
  gem 'selenium-webdriver', '>= 2.5.0'
  gem "guard-rspec"
  gem "guard-livereload"
  gem 'growl', require: false
  gem 'rb-fsevent', require: false
  gem 'cover_me'
  gem 'database_cleaner'
  gem 'spork-rails'
end

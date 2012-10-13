require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] = 'test'
  require "rails/application"
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  require 'cover_me'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'capybara/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false
    config.before(:each) do
      if example.metadata[:js]
        DatabaseCleaner.strategy = :truncation
      else
        DatabaseCleaner.strategy = :transaction
      end
      DatabaseCleaner.start
    end
    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.include(LoginMacros)
    config.include(MailerMacros)
    config.include Devise::TestHelpers, type: :controller

  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  require 'factory_girl_rails'
  FactoryGirl.reload # TODO: not sure if effective
end

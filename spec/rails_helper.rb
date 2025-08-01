# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
require "view_component/test_helpers"
require "view_component/system_test_helpers"
require "capybara/rspec"
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
# Uncomment the line below in case you have `--require rails_helper` in the `.rspec` file
# that will avoid rails generators crashing because migrations haven't been run yet
# return unless Rails.env.test?
require 'rspec/rails'
require 'devise'

# Add additional requires below this line. Rails is not loaded until this point!
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# Ensures that the test database schema matches the current schema file.
# If there are pending migrations it will invoke `db:test:prepare` to
# recreate the test database by loading the schema.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  config.include Warden::Test::Helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include ViewComponent::SystemSpecHelpers, type: :feature
  config.include ViewComponent::SystemSpecHelpers, type: :system
  config.include FactoryBot::Syntax::Methods

  # url_for doesn't work in components for whatever the fuck reason, we'll just trust it works
  RSpec.configure do |config|
    config.before(:each, type: :component) do
      allow_any_instance_of(ViewComponent::Base)
        .to receive(:url_for)
        .and_return("")
    end
  end

  # sign in as admin for any actions that requires admin access
  config.before(:each, type: :request, admin: true) do
    @admin = User.find_or_initialize_by(email: "admin@example.com") do |user|
      user.email = "admin@example.com"
      user.display_name = "Admin"
      user.password = "Password1!"
      user.username = "admin"
      user.role = "admin"
    end

    @admin.skip_confirmation! if @admin.respond_to?(:skip_confirmation!)
    @admin.confirmed_at ||= Time.current
    @admin.save! if @admin.changed?

    sign_in @admin, scope: :user
  end

  # sign in as a normal user to test access permissions
  config.before(:each, type: :request, authorization_test: true) do
    sign_out @admin
    user = User.find_or_initialize_by(email: "customer@example.com") do |user|
      user.email = "customer@exmaple.com"
      user.display_name = "Customer"
      user.password = "Password1!"
      user.username = "customer"
      user.role = "customer"
    end

    user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
    user.confirmed_at ||= Time.current
    user.save! if user.changed?

    sign_in user, scope: :user
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails uses metadata to mix in different behaviours to your tests,
  # for example enabling you to call `get` and `post` in request specs. e.g.:
  #
  #     RSpec.describe UsersController, type: :request do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/8-0/rspec-rails
  #
  # You can also this infer these behaviours automatically by location, e.g.
  # /spec/models would pull in the same behaviour as `type: :model` but this
  # behaviour is considered legacy and will be removed in a future version.
  #
  # To enable this behaviour uncomment the line below.
  # config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

# frozen_string_literal: true

require_relative "../config/environments"
require "spec_helper"

RSpec.describe Settings, type: :system do
  test "settings file is syntactically valid YAML and ERB" do
    [ "production", "development", "test" ].each do |env|
      filename = "#{env}.yml"

      assert_nothing_raised do
        production_config = Settings.load_files(Rails.root.join("config", "settings", filename))

        Settings.load_and_set_settings(production_config)
      end
    end
  end
end

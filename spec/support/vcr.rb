# frozen_string_literal: true

require "webmock/rspec"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data("<CLIENT_ID>") do |interaction|
    client_id_match = interaction.request.body.match(/client_id.+?(\S+)/m)

    client_id_match[1] if client_id_match
  end

  config.filter_sensitive_data("<CLIENT_SECRET>") do |interaction|
    client_secret_match = interaction.request.body.match(/client_secret.+?(\S+)/m)

    client_secret_match[1] if client_secret_match
  end

  config.filter_sensitive_data("<ACCESS_TOKEN>") do |interaction|
    interaction.request.headers["Authorization"]&.first
  end

  config.filter_sensitive_data("<ACCESS_TOKEN>") do |interaction|
    access_token_match = interaction.response.body.match(/"access_token":"(\S+)"/m)

    access_token_match[1] if access_token_match
  end
end

# frozen_string_literal: true

module Fixtures
  def fixture(path)
    File.join(__dir__, "../fixtures/#{path}")
  end
end

RSpec.configure do |config|
  config.include Fixtures
end

# frozen_string_literal: true

require 'English'
require 'minitest/autorun'
require 'minitest/ci'

# uncomment this to get JUnit XML
# Minitest::Ci.report_dir = "#{ENV.fetch('COVERAGE_ROOT')}/junit"

def require_app(required)
  require_relative "../code/#{required}"
end

class TestBase < Minitest::Test
end
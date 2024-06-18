# frozen_string_literal: true

require 'English'
require 'minitest/autorun'
require 'minitest/ci'

Minitest::Ci.report_dir = "#{ENV.fetch('COVERAGE_ROOT')}/junit"

def require_app(required)
  require_relative "../../app/#{required}"
end

class ReadyTest < Minitest::Test

  def test_ready
    assert_equal 1, 1
  end

end

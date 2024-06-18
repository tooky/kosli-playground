# frozen_string_literal: true

require_relative 'test_base'
require_app 'prober'

class ProbeTest < TestBase

  def test_ready
    assert_equal true, Prober.new.ready?
  end

end

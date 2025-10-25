# frozen_string_literal: true

require "test_helper"

class Simple::Json::TestParser < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Simple::Json::Parser::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end

# frozen_string_literal: true

require "test_helper"

class HelpersTest < Minitest::Test
  def test_builds_registry_with_custom_helper
    registry = Tpeg::Helpers.registry(join: ->(left, right) { "#{left}:#{right}" })

    assert_equal "Ruby:Go", Tpeg::Helpers.call("join", ["Ruby", "Go"], registry)
  end

  def test_raises_when_custom_helper_is_not_callable
    error = assert_raises(Tpeg::Error) do
      Tpeg::Helpers.registry(join: "not callable")
    end

    assert_equal "helper must respond to call: join", error.message
  end

  def test_raises_for_unknown_helper
    error = assert_raises(Tpeg::Error) do
      Tpeg::Helpers.call("unknown", [], Tpeg::Helpers.registry)
    end

    assert_equal "unknown helper: unknown", error.message
  end
end

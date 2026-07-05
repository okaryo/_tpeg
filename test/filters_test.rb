# frozen_string_literal: true

require "test_helper"

class FiltersTest < Minitest::Test
  def test_applies_builtin_upcase_filter
    assert_equal "RUBY", Tpeg::Filters.apply("upcase", "Ruby")
  end

  def test_builds_registry_with_custom_filter
    registry = Tpeg::Filters.registry(bracket: ->(value) { "[#{value}]" })

    assert_equal "[Ruby]", Tpeg::Filters.apply("bracket", "Ruby", registry)
  end

  def test_custom_filter_overrides_builtin_filter
    registry = Tpeg::Filters.registry(upcase: ->(value) { "#{value}!" })

    assert_equal "Ruby!", Tpeg::Filters.apply("upcase", "Ruby", registry)
  end

  def test_raises_when_custom_filter_is_not_callable
    error = assert_raises(Tpeg::Error) do
      Tpeg::Filters.registry(bracket: "not callable")
    end

    assert_equal "filter must respond to call: bracket", error.message
  end

  def test_raises_for_unknown_filter
    error = assert_raises(Tpeg::Error) do
      Tpeg::Filters.apply("unknown", "Ruby")
    end

    assert_equal "unknown filter: unknown", error.message
  end
end

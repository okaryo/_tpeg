# frozen_string_literal: true

require "test_helper"

class FiltersTest < Minitest::Test
  def test_applies_builtin_upcase_filter
    assert_equal "RUBY", Tpeg::Filters.apply("upcase", "Ruby")
  end

  def test_raises_for_unknown_filter
    error = assert_raises(Tpeg::Error) do
      Tpeg::Filters.apply("unknown", "Ruby")
    end

    assert_equal "unknown filter: unknown", error.message
  end
end

# frozen_string_literal: true

require "test_helper"

class RenderContextTest < Minitest::Test
  def test_looks_up_string_key
    context = Tpeg::RenderContext.new("name" => "Ruby")

    assert_equal "Ruby", context.lookup("name")
  end

  def test_looks_up_symbol_key
    context = Tpeg::RenderContext.new(name: "Ruby")

    assert_equal "Ruby", context.lookup("name")
  end

  def test_prefers_string_key_over_symbol_key
    context = Tpeg::RenderContext.new("name" => "String Ruby", name: "Symbol Ruby")

    assert_equal "String Ruby", context.lookup("name")
  end

  def test_raises_for_missing_variable
    context = Tpeg::RenderContext.new({})

    error = assert_raises(Tpeg::MissingVariable) do
      context.lookup("name")
    end

    assert_equal "missing variable: name", error.message
  end

  def test_raises_for_invalid_context
    error = assert_raises(Tpeg::InvalidContext) do
      Tpeg::RenderContext.new(Object.new)
    end

    assert_equal "render context must respond to key? and []", error.message
  end
end

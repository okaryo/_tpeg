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

  def test_looks_up_nested_string_keys
    context = Tpeg::RenderContext.new("user" => { "name" => "Ruby" })

    assert_equal "Ruby", context.lookup("user.name")
  end

  def test_looks_up_nested_symbol_keys
    context = Tpeg::RenderContext.new(user: { name: "Ruby" })

    assert_equal "Ruby", context.lookup("user.name")
  end

  def test_raises_for_missing_variable
    context = Tpeg::RenderContext.new({})

    error = assert_raises(Tpeg::MissingVariable) do
      context.lookup("name")
    end

    assert_equal "missing variable: name", error.message
  end

  def test_raises_for_missing_nested_variable
    context = Tpeg::RenderContext.new(user: {})

    error = assert_raises(Tpeg::MissingVariable) do
      context.lookup("user.name")
    end

    assert_equal "missing variable: user.name", error.message
  end

  def test_raises_when_nested_value_is_not_hash_like
    context = Tpeg::RenderContext.new(user: "Ruby")

    error = assert_raises(Tpeg::MissingVariable) do
      context.lookup("user.name")
    end

    assert_equal "missing variable: user.name", error.message
  end

  def test_raises_for_invalid_context
    error = assert_raises(Tpeg::InvalidContext) do
      Tpeg::RenderContext.new(Object.new)
    end

    assert_equal "render context must respond to key? and []", error.message
  end

  def test_copies_context_values_on_initialize
    values = { name: "Ruby" }
    context = Tpeg::RenderContext.new(values)

    values[:name] = "Changed"

    assert_equal "Ruby", context.lookup("name")
  end

  def test_child_context_looks_up_local_value
    context = Tpeg::RenderContext.new({}).with_locals(name: "Ruby")

    assert_equal "Ruby", context.lookup("name")
  end

  def test_child_context_falls_back_to_parent
    context = Tpeg::RenderContext.new(name: "Ruby").with_locals({})

    assert_equal "Ruby", context.lookup("name")
  end

  def test_child_context_prefers_local_value_over_parent
    context = Tpeg::RenderContext.new(name: "Parent").with_locals(name: "Local")

    assert_equal "Local", context.lookup("name")
  end

  def test_child_context_local_top_level_key_shadows_parent_nested_value
    context = Tpeg::RenderContext.new(user: { name: "Parent" }).with_locals(user: {})

    error = assert_raises(Tpeg::MissingVariable) do
      context.lookup("user.name")
    end

    assert_equal "missing variable: user.name", error.message
  end
end

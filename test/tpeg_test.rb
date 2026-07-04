# frozen_string_literal: true

require "test_helper"

class TpegTest < Minitest::Test
  def test_renders_plain_text_unchanged
    assert_equal "hello", Tpeg.render("hello")
  end

  def test_interpolates_string_key
    assert_equal "Hello, Ruby!", Tpeg.render("Hello, {{ name }}!", "name" => "Ruby")
  end

  def test_interpolates_symbol_key
    assert_equal "Hello, Ruby!", Tpeg.render("Hello, {{ name }}!", name: "Ruby")
  end

  def test_interpolates_adjacent_markers
    assert_equal "ab", Tpeg.render("{{ a }}{{ b }}", a: "a", b: "b")
  end

  def test_converts_values_to_strings
    assert_equal "count: 3", Tpeg.render("count: {{ count }}", count: 3)
  end

  def test_interpolates_nested_hash_value
    assert_equal "Hello, Ruby!", Tpeg.render("Hello, {{ user.name }}!", user: { name: "Ruby" })
  end

  def test_raises_for_missing_variable
    error = assert_raises(Tpeg::MissingVariable) do
      Tpeg.render("Hello, {{ name }}!")
    end

    assert_equal "missing variable: name", error.message
  end

  def test_raises_for_unterminated_interpolation
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg.render("Hello, {{ name")
    end

    assert_equal "unterminated interpolation", error.message
  end

  def test_raises_for_unexpected_closing_delimiter
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg.render("Hello }}")
    end

    assert_equal "unexpected closing delimiter", error.message
  end

  def test_raises_for_empty_interpolation
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg.render("Hello, {{ }}!")
    end

    assert_equal "empty interpolation", error.message
  end

  def test_raises_for_invalid_variable_name
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg.render("Hello, {{ user..name }}!", user: { name: "Ruby" })
    end

    assert_equal 'invalid variable name: "user..name"', error.message
  end

  def test_raises_for_invalid_context
    error = assert_raises(Tpeg::InvalidContext) do
      Tpeg.render("Hello, {{ name }}!", Object.new)
    end

    assert_equal "render context must respond to key? and []", error.message
  end
end

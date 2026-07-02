# frozen_string_literal: true

require "test_helper"

class LexerTest < Minitest::Test
  def test_tokenizes_plain_text
    tokens = Tpeg::Lexer.new("hello").tokens

    assert_equal [Tpeg::Token.new(type: :text, value: "hello")], tokens
  end

  def test_tokenizes_text_and_interpolation
    tokens = Tpeg::Lexer.new("Hello, {{ name }}!").tokens

    assert_equal(
      [
        Tpeg::Token.new(type: :text, value: "Hello, "),
        Tpeg::Token.new(type: :interpolation, value: " name "),
        Tpeg::Token.new(type: :text, value: "!")
      ],
      tokens
    )
  end

  def test_tokenizes_adjacent_interpolations
    tokens = Tpeg::Lexer.new("{{ a }}{{ b }}").tokens

    assert_equal(
      [
        Tpeg::Token.new(type: :interpolation, value: " a "),
        Tpeg::Token.new(type: :interpolation, value: " b ")
      ],
      tokens
    )
  end

  def test_preserves_text_between_delimiters
    tokens = Tpeg::Lexer.new("a\n  {{ name }}\n b").tokens

    assert_equal "a\n  ", tokens[0].value
    assert_equal "\n b", tokens[2].value
  end

  def test_raises_for_unterminated_interpolation
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg::Lexer.new("Hello, {{ name").tokens
    end

    assert_equal "unterminated interpolation", error.message
  end

  def test_raises_for_unexpected_closing_delimiter
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg::Lexer.new("Hello }}").tokens
    end

    assert_equal "unexpected closing delimiter", error.message
  end
end

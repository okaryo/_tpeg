# frozen_string_literal: true

require "test_helper"

class LexerTest < Minitest::Test
  def test_tokenizes_plain_text
    tokens = Tpeg::Lexer.new("hello").tokens

    assert_token tokens[0], type: :text, value: "hello", start_offset: 0, end_offset: 5, line: 1, column: 1
  end

  def test_tokenizes_text_and_interpolation
    tokens = Tpeg::Lexer.new("Hello, {{ name }}!").tokens

    assert_token tokens[0], type: :text, value: "Hello, ", start_offset: 0, end_offset: 7, line: 1, column: 1
    assert_token tokens[1], type: :interpolation, value: "name", start_offset: 10, end_offset: 14, line: 1, column: 11
    assert_token tokens[2], type: :text, value: "!", start_offset: 17, end_offset: 18, line: 1, column: 18
  end

  def test_tokenizes_adjacent_interpolations
    tokens = Tpeg::Lexer.new("{{ a }}{{ b }}").tokens

    assert_token tokens[0], type: :interpolation, value: "a", start_offset: 3, end_offset: 4, line: 1, column: 4
    assert_token tokens[1], type: :interpolation, value: "b", start_offset: 10, end_offset: 11, line: 1, column: 11
  end

  def test_tokenizes_control_tag
    tokens = Tpeg::Lexer.new("Hello {% if user %}!").tokens

    assert_token tokens[0], type: :text, value: "Hello ", start_offset: 0, end_offset: 6, line: 1, column: 1
    assert_token tokens[1], type: :tag, value: "if user", start_offset: 9, end_offset: 16, line: 1, column: 10
    assert_token tokens[2], type: :text, value: "!", start_offset: 19, end_offset: 20, line: 1, column: 20
  end

  def test_preserves_text_between_delimiters
    tokens = Tpeg::Lexer.new("a\n  {{ name }}\n b").tokens

    assert_equal "a\n  ", tokens[0].value
    assert_equal "\n b", tokens[2].value
  end

  def test_tracks_multiline_token_positions
    tokens = Tpeg::Lexer.new("a\n  {{ name }}\n b").tokens

    assert_token tokens[1], type: :interpolation, value: "name", start_offset: 7, end_offset: 11, line: 2, column: 6
    assert_token tokens[2], type: :text, value: "\n b", start_offset: 14, end_offset: 17, line: 2, column: 13
  end

  def test_trims_multiline_interpolation_whitespace
    tokens = Tpeg::Lexer.new("{{\n  name\n}}").tokens

    assert_token tokens[0], type: :interpolation, value: "name", start_offset: 5, end_offset: 9, line: 2, column: 3
  end

  def test_trims_multiline_control_tag_whitespace
    tokens = Tpeg::Lexer.new("{%\n  if user\n%}").tokens

    assert_token tokens[0], type: :tag, value: "if user", start_offset: 5, end_offset: 12, line: 2, column: 3
  end

  def test_whitespace_only_interpolation_becomes_empty_token
    tokens = Tpeg::Lexer.new("{{   }}").tokens

    assert_token tokens[0], type: :interpolation, value: "", start_offset: 5, end_offset: 5, line: 1, column: 6
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

  def test_raises_for_unterminated_control_tag
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg::Lexer.new("Hello {% if user").tokens
    end

    assert_equal "unterminated tag", error.message
  end

  def test_raises_for_unexpected_control_tag_closing_delimiter
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg::Lexer.new("Hello %}").tokens
    end

    assert_equal "unexpected closing delimiter", error.message
  end

  private

  def assert_token(token, type:, value:, start_offset:, end_offset:, line:, column:)
    assert_equal type, token.type
    assert_equal value, token.value
    assert_equal start_offset, token.start_offset
    assert_equal end_offset, token.end_offset
    assert_equal line, token.line
    assert_equal column, token.column
  end
end

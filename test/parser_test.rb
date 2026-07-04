# frozen_string_literal: true

require "test_helper"

class ParserTest < Minitest::Test
  def test_parses_text_tokens_into_text_nodes
    nodes = parse("hello")

    assert_equal 1, nodes.length
    assert_text_node nodes[0], value: "hello", start_offset: 0, end_offset: 5, line: 1, column: 1
  end

  def test_parses_interpolation_tokens_into_variable_nodes
    nodes = parse("Hello, {{ name }}!")

    assert_text_node nodes[0], value: "Hello, ", start_offset: 0, end_offset: 7, line: 1, column: 1
    assert_variable_node nodes[1], name: "name", start_offset: 10, end_offset: 14, line: 1, column: 11
    assert_text_node nodes[2], value: "!", start_offset: 17, end_offset: 18, line: 1, column: 18
  end

  def test_preserves_node_source_position_from_tokens
    nodes = parse("a\n  {{ name }}")

    assert_variable_node nodes[1], name: "name", start_offset: 7, end_offset: 11, line: 2, column: 6
  end

  def test_raises_for_empty_interpolation
    error = assert_raises(Tpeg::SyntaxError) do
      parse("Hello, {{ }}!")
    end

    assert_equal "empty interpolation", error.message
  end

  def test_raises_for_invalid_variable_name
    error = assert_raises(Tpeg::SyntaxError) do
      parse("Hello, {{ user.name }}!")
    end

    assert_equal 'invalid variable name: "user.name"', error.message
  end

  def test_raises_for_unknown_token_type
    token = Tpeg::Token.new(type: :unknown, value: "x", start_offset: 0, end_offset: 1, line: 1, column: 1)

    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg::Parser.new([token]).nodes
    end

    assert_equal "unknown token type: :unknown", error.message
  end

  private

  def parse(source)
    Tpeg::Parser.new(Tpeg::Lexer.new(source).tokens).nodes
  end

  def assert_text_node(node, value:, start_offset:, end_offset:, line:, column:)
    assert_instance_of Tpeg::TextNode, node
    assert_equal value, node.value
    assert_source_position node, start_offset: start_offset, end_offset: end_offset, line: line, column: column
  end

  def assert_variable_node(node, name:, start_offset:, end_offset:, line:, column:)
    assert_instance_of Tpeg::VariableNode, node
    assert_equal name, node.name
    assert_source_position node, start_offset: start_offset, end_offset: end_offset, line: line, column: column
  end

  def assert_source_position(node, start_offset:, end_offset:, line:, column:)
    assert_equal start_offset, node.start_offset
    assert_equal end_offset, node.end_offset
    assert_equal line, node.line
    assert_equal column, node.column
  end
end

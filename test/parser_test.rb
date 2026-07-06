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

  def test_parses_dotted_variable_path
    nodes = parse("Hello, {{ user.name }}!")

    assert_variable_node nodes[1], name: "user.name", start_offset: 10, end_offset: 19, line: 1, column: 11
  end

  def test_parses_variable_filters
    nodes = parse("Hello, {{ name | upcase }}!")

    assert_variable_node nodes[1], name: "name", filters: ["upcase"], start_offset: 10, end_offset: 23, line: 1, column: 11
  end

  def test_parses_helper_call
    nodes = parse("Hello, {{ link_to(label, url) }}!")

    assert_helper_node nodes[1],
                       name: "link_to",
                       arguments: ["label", "url"],
                       start_offset: 10,
                       end_offset: 29,
                       line: 1,
                       column: 11
  end

  def test_parses_helper_call_with_filter
    nodes = parse("Hello, {{ join(first, second) | upcase }}!")

    assert_helper_node nodes[1],
                       name: "join",
                       arguments: ["first", "second"],
                       filters: ["upcase"],
                       start_offset: 10,
                       end_offset: 38,
                       line: 1,
                       column: 11
  end

  def test_raises_for_unknown_tag
    error = assert_raises(Tpeg::SyntaxError) do
      parse("Hello {% unknown user %}!")
    end

    assert_equal 'unknown tag: "unknown user"', error.message
  end

  def test_parses_if_block_into_if_node
    nodes = parse("Hello {% if user %}{{ user.name }}{% end %}!")

    assert_text_node nodes[0], value: "Hello ", start_offset: 0, end_offset: 6, line: 1, column: 1
    assert_if_node nodes[1], condition: "user", start_offset: 9, end_offset: 16, line: 1, column: 10
    assert_variable_node nodes[1].children[0], name: "user.name", start_offset: 22, end_offset: 31, line: 1, column: 23
    assert_text_node nodes[2], value: "!", start_offset: 43, end_offset: 44, line: 1, column: 44
  end

  def test_parses_nested_if_blocks
    nodes = parse("{% if user %}{% if user.active %}yes{% end %}{% end %}")

    assert_if_node nodes[0], condition: "user", start_offset: 3, end_offset: 10, line: 1, column: 4
    assert_if_node nodes[0].children[0], condition: "user.active", start_offset: 16, end_offset: 30, line: 1, column: 17
    assert_text_node nodes[0].children[0].children[0], value: "yes", start_offset: 33, end_offset: 36, line: 1, column: 34
  end

  def test_parses_for_block_into_for_node
    nodes = parse("{% for item in items %}{{ item.name }}{% end %}")

    assert_for_node nodes[0], local_name: "item", collection: "items", start_offset: 3, end_offset: 20, line: 1, column: 4
    assert_variable_node nodes[0].children[0], name: "item.name", start_offset: 26, end_offset: 35, line: 1, column: 27
  end

  def test_parses_if_inside_for_block
    nodes = parse("{% for item in items %}{% if item.active %}yes{% end %}{% end %}")

    assert_for_node nodes[0], local_name: "item", collection: "items", start_offset: 3, end_offset: 20, line: 1, column: 4
    assert_if_node nodes[0].children[0], condition: "item.active", start_offset: 26, end_offset: 40, line: 1, column: 27
    assert_text_node nodes[0].children[0].children[0], value: "yes", start_offset: 43, end_offset: 46, line: 1, column: 44
  end

  def test_parses_render_tag_into_partial_node
    nodes = parse("Hello {% render greeting %}!")

    assert_text_node nodes[0], value: "Hello ", start_offset: 0, end_offset: 6, line: 1, column: 1
    assert_partial_node nodes[1], name: "greeting", start_offset: 9, end_offset: 24, line: 1, column: 10
    assert_text_node nodes[2], value: "!", start_offset: 27, end_offset: 28, line: 1, column: 28
  end

  def test_raises_for_empty_interpolation
    error = assert_raises(Tpeg::SyntaxError) do
      parse("Hello, {{ }}!")
    end

    assert_equal "empty interpolation", error.message
  end

  def test_raises_for_invalid_variable_name
    error = assert_raises(Tpeg::SyntaxError) do
      parse("Hello, {{ user..name }}!")
    end

    assert_equal 'invalid variable name: "user..name"', error.message
  end

  def test_raises_for_invalid_filter_name
    error = assert_raises(Tpeg::SyntaxError) do
      parse("Hello, {{ name | }}!")
    end

    assert_equal 'invalid filter name: ""', error.message
  end

  def test_raises_for_invalid_helper_argument
    error = assert_raises(Tpeg::SyntaxError) do
      parse("Hello, {{ link_to(label, ) }}!")
    end

    assert_equal 'invalid helper argument: ""', error.message
  end

  def test_raises_for_unknown_token_type
    token = Tpeg::Token.new(type: :unknown, value: "x", start_offset: 0, end_offset: 1, line: 1, column: 1)

    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg::Parser.new([token]).nodes
    end

    assert_equal "unknown token type: :unknown", error.message
  end

  def test_raises_for_unexpected_end_tag
    error = assert_raises(Tpeg::SyntaxError) do
      parse("Hello {% end %}")
    end

    assert_equal "unexpected end tag", error.message
  end

  def test_raises_for_unterminated_if_block
    error = assert_raises(Tpeg::SyntaxError) do
      parse("Hello {% if user %}")
    end

    assert_equal "unterminated if block", error.message
  end

  def test_raises_for_invalid_for_tag
    error = assert_raises(Tpeg::SyntaxError) do
      parse("{% for item items %}{% end %}")
    end

    assert_equal 'invalid for tag: "for item items"', error.message
  end

  def test_raises_for_invalid_render_tag
    error = assert_raises(Tpeg::SyntaxError) do
      parse("{% render %}")
    end

    assert_equal 'invalid render tag: "render"', error.message
  end

  def test_raises_for_unterminated_for_block
    error = assert_raises(Tpeg::SyntaxError) do
      parse("{% for item in items %}")
    end

    assert_equal "unterminated for block", error.message
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

  def assert_variable_node(node, name:, filters: [], start_offset:, end_offset:, line:, column:)
    assert_instance_of Tpeg::VariableNode, node
    assert_equal name, node.name
    assert_equal filters, node.filters
    assert_source_position node, start_offset: start_offset, end_offset: end_offset, line: line, column: column
  end

  def assert_helper_node(node, name:, arguments:, filters: [], start_offset:, end_offset:, line:, column:)
    assert_instance_of Tpeg::HelperNode, node
    assert_equal name, node.name
    assert_equal arguments, node.arguments
    assert_equal filters, node.filters
    assert_source_position node, start_offset: start_offset, end_offset: end_offset, line: line, column: column
  end

  def assert_if_node(node, condition:, start_offset:, end_offset:, line:, column:)
    assert_instance_of Tpeg::IfNode, node
    assert_equal condition, node.condition
    assert_source_position node, start_offset: start_offset, end_offset: end_offset, line: line, column: column
  end

  def assert_for_node(node, local_name:, collection:, start_offset:, end_offset:, line:, column:)
    assert_instance_of Tpeg::ForNode, node
    assert_equal local_name, node.local_name
    assert_equal collection, node.collection
    assert_source_position node, start_offset: start_offset, end_offset: end_offset, line: line, column: column
  end

  def assert_partial_node(node, name:, start_offset:, end_offset:, line:, column:)
    assert_instance_of Tpeg::PartialNode, node
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

# frozen_string_literal: true

require_relative "errors"

module Tpeg
  TextNode = Struct.new(:value, :start_offset, :end_offset, :line, :column, keyword_init: true)
  VariableNode = Struct.new(:name, :filters, :start_offset, :end_offset, :line, :column, keyword_init: true)
  HelperNode = Struct.new(:name, :arguments, :filters, :start_offset, :end_offset, :line, :column, keyword_init: true)
  IfNode = Struct.new(:condition, :children, :start_offset, :end_offset, :line, :column, keyword_init: true)
  ForNode = Struct.new(:local_name, :collection, :children, :start_offset, :end_offset, :line, :column, keyword_init: true)
  PartialNode = Struct.new(:name, :local_name, :value_path, :start_offset, :end_offset, :line, :column, keyword_init: true)

  class Parser
    VARIABLE_PATH = /\A[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*)*\z/.freeze
    FILTER_NAME = /\A[a-zA-Z_][a-zA-Z0-9_]*\z/.freeze
    HELPER_CALL = /\A([a-zA-Z_][a-zA-Z0-9_]*)\((.*)\)\z/.freeze
    FOR_TAG = /\Afor\s+([a-zA-Z_][a-zA-Z0-9_]*)\s+in\s+(.+)\z/.freeze
    PARTIAL_TAG = /\Arender\s+([a-zA-Z_][a-zA-Z0-9_\/-]*)(?:\s+with\s+(.+?)(?:\s+as\s+([a-zA-Z_][a-zA-Z0-9_]*))?)?\z/.freeze

    def initialize(tokens)
      @tokens = tokens
      @position = 0
    end

    def nodes
      parse_nodes
    end

    private

    def parse_nodes(stop_at_end: false, block_name: nil)
      nodes = []

      while current_token
        if end_tag?(current_token)
          @position += 1
          return nodes if stop_at_end

          raise SyntaxError, "unexpected end tag"
        end

        nodes << consume_node
      end

      raise SyntaxError, "unterminated #{block_name} block" if stop_at_end

      nodes
    end

    def consume_node
      token = current_token
      @position += 1

      node_for(token)
    end

    def node_for(token)
      case token.type
      when :text
        TextNode.new(**source_fields(token), value: token.value)
      when :interpolation
        expression, filters = parse_filtered_expression(token.value)
        node_for_interpolation_expression(expression, filters, token)
      when :tag
        node_for_tag(token)
      else
        raise SyntaxError, "unknown token type: #{token.type.inspect}"
      end
    end

    def node_for_tag(token)
      return parse_if_node(token) if token.value.start_with?("if ")
      return parse_for_node(token) if token.value.start_with?("for ")
      return parse_partial_node(token) if token.value == "render" || token.value.start_with?("render ")

      raise SyntaxError, "unknown tag: #{token.value.inspect}"
    end

    def parse_if_node(token)
      condition = token.value.delete_prefix("if ").strip
      validate_variable_name(condition)

      IfNode.new(**source_fields(token), condition: condition, children: parse_nodes(stop_at_end: true, block_name: "if"))
    end

    def parse_for_node(token)
      match = FOR_TAG.match(token.value)
      raise SyntaxError, "invalid for tag: #{token.value.inspect}" if match.nil?

      local_name = match[1]
      collection = match[2].strip
      validate_variable_name(collection)

      ForNode.new(
        **source_fields(token),
        local_name: local_name,
        collection: collection,
        children: parse_nodes(stop_at_end: true, block_name: "for")
      )
    end

    def parse_partial_node(token)
      match = PARTIAL_TAG.match(token.value)
      raise SyntaxError, "invalid render tag: #{token.value.inspect}" if match.nil?

      name = match[1]
      value_path = match[2]&.strip
      local_name = match[3] || name
      validate_variable_name(value_path) if value_path

      PartialNode.new(**source_fields(token), name: name, local_name: local_name, value_path: value_path)
    end

    def current_token
      @tokens[@position]
    end

    def end_tag?(token)
      token.type == :tag && token.value == "end"
    end

    def validate_variable_name(name)
      raise SyntaxError, "empty interpolation" if name.empty?
      return if VARIABLE_PATH.match?(name)

      raise SyntaxError, "invalid variable name: #{name.inspect}"
    end

    def parse_filtered_expression(value)
      parts = value.split("|", -1).map(&:strip)
      expression = parts.shift || ""
      filters = parts

      raise SyntaxError, "empty interpolation" if expression.empty?

      filters.each do |filter|
        raise SyntaxError, "invalid filter name: #{filter.inspect}" unless FILTER_NAME.match?(filter)
      end

      [expression, filters]
    end

    def node_for_interpolation_expression(expression, filters, token)
      helper_match = HELPER_CALL.match(expression)
      return node_for_helper_expression(helper_match, filters, token) if helper_match

      validate_variable_name(expression)
      VariableNode.new(**source_fields(token), name: expression, filters: filters)
    end

    def node_for_helper_expression(match, filters, token)
      HelperNode.new(
        **source_fields(token),
        name: match[1],
        arguments: parse_helper_arguments(match[2]),
        filters: filters
      )
    end

    def parse_helper_arguments(source)
      return [] if source.strip.empty?

      source.split(",", -1).map(&:strip).each do |argument|
        raise SyntaxError, "invalid helper argument: #{argument.inspect}" unless VARIABLE_PATH.match?(argument)
      end
    end

    def source_fields(token)
      {
        start_offset: token.start_offset,
        end_offset: token.end_offset,
        line: token.line,
        column: token.column
      }
    end
  end
end

# frozen_string_literal: true

require_relative "errors"

module Tpeg
  TextNode = Struct.new(:value, :start_offset, :end_offset, :line, :column, keyword_init: true)
  VariableNode = Struct.new(:name, :start_offset, :end_offset, :line, :column, keyword_init: true)
  TagNode = Struct.new(:value, :start_offset, :end_offset, :line, :column, keyword_init: true)
  IfNode = Struct.new(:condition, :children, :start_offset, :end_offset, :line, :column, keyword_init: true)

  class Parser
    VARIABLE_PATH = /\A[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*)*\z/.freeze

    def initialize(tokens)
      @tokens = tokens
      @position = 0
    end

    def nodes
      parse_nodes
    end

    private

    def parse_nodes(stop_at_end: false)
      nodes = []

      while current_token
        if end_tag?(current_token)
          @position += 1
          return nodes if stop_at_end

          raise SyntaxError, "unexpected end tag"
        end

        nodes << consume_node
      end

      raise SyntaxError, "unterminated if block" if stop_at_end

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
        validate_variable_name(token.value)
        VariableNode.new(**source_fields(token), name: token.value)
      when :tag
        node_for_tag(token)
      else
        raise SyntaxError, "unknown token type: #{token.type.inspect}"
      end
    end

    def node_for_tag(token)
      return parse_if_node(token) if token.value.start_with?("if ")

      TagNode.new(**source_fields(token), value: token.value)
    end

    def parse_if_node(token)
      condition = token.value.delete_prefix("if ").strip
      validate_variable_name(condition)

      IfNode.new(**source_fields(token), condition: condition, children: parse_nodes(stop_at_end: true))
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

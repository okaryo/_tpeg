# frozen_string_literal: true

require_relative "errors"

module Tpeg
  TextNode = Struct.new(:value, :start_offset, :end_offset, :line, :column, keyword_init: true)
  VariableNode = Struct.new(:name, :start_offset, :end_offset, :line, :column, keyword_init: true)
  TagNode = Struct.new(:value, :start_offset, :end_offset, :line, :column, keyword_init: true)

  class Parser
    VARIABLE_PATH = /\A[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*)*\z/.freeze

    def initialize(tokens)
      @tokens = tokens
    end

    def nodes
      @tokens.map { |token| node_for(token) }
    end

    private

    def node_for(token)
      case token.type
      when :text
        TextNode.new(**source_fields(token), value: token.value)
      when :interpolation
        validate_variable_name(token.value)
        VariableNode.new(**source_fields(token), name: token.value)
      when :tag
        TagNode.new(**source_fields(token), value: token.value)
      else
        raise SyntaxError, "unknown token type: #{token.type.inspect}"
      end
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

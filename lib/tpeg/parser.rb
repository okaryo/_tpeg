# frozen_string_literal: true

require_relative "errors"

module Tpeg
  TextNode = Struct.new(:value, :start_offset, :end_offset, :line, :column, keyword_init: true)
  VariableNode = Struct.new(:name, :start_offset, :end_offset, :line, :column, keyword_init: true)

  class Parser
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
        VariableNode.new(**source_fields(token), name: token.value)
      else
        raise SyntaxError, "unknown token type: #{token.type.inspect}"
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

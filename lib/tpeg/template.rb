# frozen_string_literal: true

require_relative "errors"
require_relative "lexer"

module Tpeg
  class Template
    IDENTIFIER = /\A[a-zA-Z_][a-zA-Z0-9_]*\z/.freeze

    def initialize(source)
      @source = String(source)
    end

    def render(context = {})
      output = +""

      Lexer.new(@source).tokens.each do |token|
        output << render_token(token, context)
      end

      output
    end

    private

    def render_token(token, context)
      case token.type
      when :text
        token.value
      when :interpolation
        render_interpolation(token.value, context)
      else
        raise Error, "unknown token type: #{token.type.inspect}"
      end
    end

    def render_interpolation(name, context)
      validate_variable_name(name)

      lookup(context, name).to_s
    end

    def validate_variable_name(name)
      raise SyntaxError, "empty interpolation" if name.empty?
      return if IDENTIFIER.match?(name)

      raise SyntaxError, "invalid variable name: #{name.inspect}"
    end

    def lookup(context, name)
      return context[name] if context.respond_to?(:key?) && context.key?(name)

      symbol_name = name.to_sym
      return context[symbol_name] if context.respond_to?(:key?) && context.key?(symbol_name)

      raise MissingVariable, "missing variable: #{name}"
    end
  end
end

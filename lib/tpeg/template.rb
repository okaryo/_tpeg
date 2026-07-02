# frozen_string_literal: true

require "strscan"

module Tpeg
  class Error < StandardError; end
  class SyntaxError < Error; end
  class MissingVariable < Error; end

  class Template
    IDENTIFIER = /\A[a-zA-Z_][a-zA-Z0-9_]*\z/.freeze

    def initialize(source)
      @source = String(source)
    end

    def render(context = {})
      scanner = StringScanner.new(@source)
      output = +""

      until scanner.eos?
        if scanner.scan(/{{/)
          output << render_interpolation(scanner, context)
        elsif scanner.scan(/}}/)
          raise SyntaxError, "unexpected closing delimiter"
        else
          output << scanner.getch
        end
      end

      output
    end

    private

    def render_interpolation(scanner, context)
      expression = scanner.scan_until(/}}/)
      raise SyntaxError, "unterminated interpolation" if expression.nil?

      name = expression[0...-2].strip
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

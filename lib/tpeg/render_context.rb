# frozen_string_literal: true

require_relative "errors"

module Tpeg
  class RenderContext
    def initialize(values)
      @values = values
    end

    def lookup(name)
      return @values[name] if key?(name)

      symbol_name = name.to_sym
      return @values[symbol_name] if key?(symbol_name)

      raise MissingVariable, "missing variable: #{name}"
    end

    private

    def key?(name)
      @values.respond_to?(:key?) && @values.key?(name)
    end
  end
end

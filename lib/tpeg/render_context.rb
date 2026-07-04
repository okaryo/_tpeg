# frozen_string_literal: true

require_relative "errors"

module Tpeg
  class RenderContext
    def initialize(values)
      unless values.respond_to?(:key?) && values.respond_to?(:[])
        raise InvalidContext, "render context must respond to key? and []"
      end

      @values = values.dup.freeze
    end

    def lookup(name)
      return @values[name] if key?(name)

      symbol_name = name.to_sym
      return @values[symbol_name] if key?(symbol_name)

      raise MissingVariable, "missing variable: #{name}"
    end

    private

    def key?(name)
      @values.key?(name)
    end
  end
end

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
      name.split(".").reduce(@values) do |current_values, part|
        lookup_part(current_values, part, name)
      end
    end

    private

    def lookup_part(values, part, full_name)
      unless values.respond_to?(:key?) && values.respond_to?(:[])
        raise MissingVariable, "missing variable: #{full_name}"
      end

      return values[part] if values.key?(part)

      symbol_part = part.to_sym
      return values[symbol_part] if values.key?(symbol_part)

      raise MissingVariable, "missing variable: #{full_name}"
    end
  end
end

# frozen_string_literal: true

require_relative "errors"

module Tpeg
  class RenderContext
    def initialize(values, parent = nil)
      unless values.respond_to?(:key?) && values.respond_to?(:[])
        raise InvalidContext, "render context must respond to key? and []"
      end

      @values = values.dup.freeze
      @parent = parent
    end

    def with_locals(values)
      self.class.new(values, self)
    end

    def lookup(name)
      parts = name.split(".")

      if has_part?(@values, parts.first)
        lookup_parts(@values, parts, name)
      elsif @parent
        @parent.lookup(name)
      else
        raise MissingVariable, "missing variable: #{name}"
      end
    end

    private

    def lookup_parts(values, parts, full_name)
      parts.reduce(values) do |current_values, part|
        lookup_part(current_values, part, full_name)
      end
    end

    def lookup_part(values, part, full_name)
      unless values.respond_to?(:key?) && values.respond_to?(:[])
        raise MissingVariable, "missing variable: #{full_name}"
      end

      return values[part] if values.key?(part)

      symbol_part = part.to_sym
      return values[symbol_part] if values.key?(symbol_part)

      raise MissingVariable, "missing variable: #{full_name}"
    end

    def has_part?(values, part)
      values.key?(part) || values.key?(part.to_sym)
    end
  end
end

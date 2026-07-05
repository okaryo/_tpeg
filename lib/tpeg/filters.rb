# frozen_string_literal: true

require_relative "errors"

module Tpeg
  module Filters
    BUILT_INS = {
      "upcase" => ->(value) { value.to_s.upcase }
    }.freeze

    def self.registry(custom_filters = {})
      raise Error, "filters must respond to each" unless custom_filters.respond_to?(:each)

      custom_filters.each_with_object(BUILT_INS.dup) do |(name, filter), filters|
        name = name.to_s
        raise Error, "filter must respond to call: #{name}" unless filter.respond_to?(:call)

        filters[name] = filter
      end.freeze
    end

    def self.apply(name, value, registry = BUILT_INS)
      filter = registry[name]
      raise Error, "unknown filter: #{name}" if filter.nil?

      filter.call(value)
    end
  end
end

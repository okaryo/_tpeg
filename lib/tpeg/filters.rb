# frozen_string_literal: true

require_relative "errors"

module Tpeg
  module Filters
    BUILT_INS = {
      "upcase" => ->(value) { value.to_s.upcase }
    }.freeze

    def self.apply(name, value)
      filter = BUILT_INS[name]
      raise Error, "unknown filter: #{name}" if filter.nil?

      filter.call(value)
    end
  end
end

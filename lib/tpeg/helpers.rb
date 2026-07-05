# frozen_string_literal: true

require_relative "errors"

module Tpeg
  module Helpers
    def self.registry(custom_helpers = {})
      raise Error, "helpers must respond to each" unless custom_helpers.respond_to?(:each)

      custom_helpers.each_with_object({}) do |(name, helper), helpers|
        name = name.to_s
        raise Error, "helper must respond to call: #{name}" unless helper.respond_to?(:call)

        helpers[name] = helper
      end.freeze
    end

    def self.call(name, arguments, registry)
      helper = registry[name]
      raise Error, "unknown helper: #{name}" if helper.nil?

      helper.call(*arguments)
    end
  end
end

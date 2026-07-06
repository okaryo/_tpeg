# frozen_string_literal: true

require_relative "errors"

module Tpeg
  class HashLoader
    def initialize(templates)
      raise Error, "templates must respond to each" unless templates.respond_to?(:each)

      @templates = templates.each_with_object({}) do |(name, source), loaded_templates|
        loaded_templates[name.to_s] = String(source)
      end.freeze
    end

    def load(name)
      source = @templates[name.to_s]
      raise Error, "template not found: #{name}" if source.nil?

      source
    end
  end
end

# frozen_string_literal: true

require "cgi"

module Tpeg
  class HtmlSafeString
    def initialize(value)
      @value = value
    end

    def to_s
      @value
    end
  end

  module HtmlEscape
    def self.escape(value)
      return value.to_s if value.is_a?(HtmlSafeString)

      CGI.escapeHTML(value.to_s)
    end
  end
end

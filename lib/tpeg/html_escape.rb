# frozen_string_literal: true

require "cgi"

module Tpeg
  module HtmlEscape
    def self.escape(value)
      CGI.escapeHTML(value.to_s)
    end
  end
end

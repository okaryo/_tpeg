# frozen_string_literal: true

require_relative "tpeg/errors"
require_relative "tpeg/html_escape"
require_relative "tpeg/lexer"
require_relative "tpeg/parser"
require_relative "tpeg/render_context"
require_relative "tpeg/template"

module Tpeg
  def self.render(source, context = {})
    Template.new(source).render(context)
  end
end

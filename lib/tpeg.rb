# frozen_string_literal: true

require_relative "tpeg/errors"
require_relative "tpeg/lexer"
require_relative "tpeg/template"

module Tpeg
  def self.render(source, context = {})
    Template.new(source).render(context)
  end
end

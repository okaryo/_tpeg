# frozen_string_literal: true

module Tpeg
  class Error < StandardError; end
  class SyntaxError < Error; end
  class MissingVariable < Error; end
end

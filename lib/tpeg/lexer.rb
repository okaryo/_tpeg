# frozen_string_literal: true

require_relative "errors"

module Tpeg
  Token = Struct.new(:type, :value, keyword_init: true)

  class Lexer
    def initialize(source)
      @source = String(source)
    end

    def tokens
      tokens = []
      cursor = 0

      while cursor < @source.length
        opening = @source.index("{{", cursor)
        closing = @source.index("}}", cursor)

        if closing && (opening.nil? || closing < opening)
          raise SyntaxError, "unexpected closing delimiter"
        end

        if opening.nil?
          tokens << Token.new(type: :text, value: @source[cursor..-1]) if cursor < @source.length
          break
        end

        tokens << Token.new(type: :text, value: @source[cursor...opening]) if cursor < opening

        interpolation_start = opening + 2
        interpolation_end = @source.index("}}", interpolation_start)
        raise SyntaxError, "unterminated interpolation" if interpolation_end.nil?

        tokens << Token.new(
          type: :interpolation,
          value: @source[interpolation_start...interpolation_end]
        )

        cursor = interpolation_end + 2
      end

      tokens
    end
  end
end

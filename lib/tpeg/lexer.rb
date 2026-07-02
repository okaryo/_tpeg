# frozen_string_literal: true

require_relative "errors"

module Tpeg
  Token = Struct.new(:type, :value, :start_offset, :end_offset, :line, :column, keyword_init: true)

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
          tokens << token(:text, @source[cursor..-1], cursor, @source.length) if cursor < @source.length
          break
        end

        tokens << token(:text, @source[cursor...opening], cursor, opening) if cursor < opening

        interpolation_start = opening + 2
        interpolation_end = @source.index("}}", interpolation_start)
        raise SyntaxError, "unterminated interpolation" if interpolation_end.nil?

        tokens << token(:interpolation, @source[interpolation_start...interpolation_end], interpolation_start, interpolation_end)

        cursor = interpolation_end + 2
      end

      tokens
    end

    private

    def token(type, value, start_index, end_index)
      line, column = line_and_column(start_index)

      Token.new(
        type: type,
        value: value,
        start_offset: byte_offset(start_index),
        end_offset: byte_offset(end_index),
        line: line,
        column: column
      )
    end

    def byte_offset(index)
      @source[0...index].bytesize
    end

    def line_and_column(index)
      before = @source[0...index]
      line = before.count("\n") + 1
      last_newline = before.rindex("\n")
      column = last_newline.nil? ? before.length + 1 : before.length - last_newline

      [line, column]
    end
  end
end

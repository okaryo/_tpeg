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
        opening = next_opening(cursor)
        closing = next_closing(cursor)

        if closing && (opening.nil? || closing[:index] < opening[:index])
          delimiter_error("unexpected closing delimiter", closing[:index])
        end

        if opening.nil?
          tokens << token(:text, @source[cursor..-1], cursor, @source.length) if cursor < @source.length
          break
        end

        opening_index = opening[:index]
        tokens << token(:text, @source[cursor...opening_index], cursor, opening_index) if cursor < opening_index

        value_start = opening_index + 2
        value_end = @source.index(opening[:close], value_start)
        delimiter_error("unterminated #{opening[:name]}", opening_index) if value_end.nil?

        value, trimmed_start, trimmed_end = trimmed_value(value_start, value_end)
        tokens << token(opening[:type], value, trimmed_start, trimmed_end)

        cursor = value_end + 2
      end

      tokens
    end

    private

    def next_opening(cursor)
      [
        { open: "{{", close: "}}", type: :interpolation, name: "interpolation", index: @source.index("{{", cursor) },
        { open: "{%", close: "%}", type: :tag, name: "tag", index: @source.index("{%", cursor) }
      ].select { |delimiter| delimiter[:index] }.min_by { |delimiter| delimiter[:index] }
    end

    def next_closing(cursor)
      [
        { close: "}}", index: @source.index("}}", cursor) },
        { close: "%}", index: @source.index("%}", cursor) }
      ].select { |delimiter| delimiter[:index] }.min_by { |delimiter| delimiter[:index] }
    end

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

    def trimmed_value(start_index, end_index)
      raw_value = @source[start_index...end_index]
      leading_whitespace = raw_value.length - raw_value.lstrip.length
      trailing_whitespace = raw_value.length - raw_value.rstrip.length

      value_start = start_index + leading_whitespace
      value_end = end_index - trailing_whitespace
      value_end = value_start if value_end < value_start
      value = @source[value_start...value_end]

      [value, value_start, value_end]
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

    def delimiter_error(message, index)
      line, column = line_and_column(index)
      raise SyntaxError, "#{message} at line #{line}, column #{column}\n#{source_line(index)}\n#{caret(column)}"
    end

    def source_line(index)
      line_start = @source.rindex("\n", index)&.+(1) || 0
      line_end = @source.index("\n", index) || @source.length

      @source[line_start...line_end]
    end

    def caret(column)
      "#{' ' * (column - 1)}^"
    end
  end
end

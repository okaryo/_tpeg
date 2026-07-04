# frozen_string_literal: true

require_relative "errors"
require_relative "lexer"
require_relative "parser"

module Tpeg
  class Template
    def initialize(source)
      @source = String(source)
    end

    def render(context = {})
      output = +""

      Parser.new(Lexer.new(@source).tokens).nodes.each do |node|
        output << render_node(node, context)
      end

      output
    end

    private

    def render_node(node, context)
      case node
      when TextNode
        node.value
      when VariableNode
        render_interpolation(node.name, context)
      else
        raise Error, "unknown node type: #{node.class}"
      end
    end

    def render_interpolation(name, context)
      lookup(context, name).to_s
    end

    def lookup(context, name)
      return context[name] if context.respond_to?(:key?) && context.key?(name)

      symbol_name = name.to_sym
      return context[symbol_name] if context.respond_to?(:key?) && context.key?(symbol_name)

      raise MissingVariable, "missing variable: #{name}"
    end
  end
end

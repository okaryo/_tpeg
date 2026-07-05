# frozen_string_literal: true

require_relative "errors"
require_relative "html_escape"
require_relative "lexer"
require_relative "parser"
require_relative "render_context"

module Tpeg
  class Template
    def initialize(source)
      @source = String(source)
    end

    def render(context = {})
      render_context = RenderContext.new(context)
      render_nodes(Parser.new(Lexer.new(@source).tokens).nodes, render_context)
    end

    private

    def render_nodes(nodes, render_context)
      output = +""

      nodes.each do |node|
        output << render_node(node, render_context)
      end

      output
    end

    def render_node(node, render_context)
      case node
      when TextNode
        node.value
      when VariableNode
        render_interpolation(node.name, render_context)
      when IfNode
        render_if(node, render_context)
      else
        raise Error, "unknown node type: #{node.class}"
      end
    end

    def render_interpolation(name, render_context)
      HtmlEscape.escape(render_context.lookup(name))
    end

    def render_if(node, render_context)
      return "" unless truthy?(render_context.lookup(node.condition))

      render_nodes(node.children, render_context)
    end

    def truthy?(value)
      !value.nil? && value != false
    end
  end
end

# frozen_string_literal: true

require_relative "errors"
require_relative "filters"
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
        render_interpolation(node.name, node.filters, render_context)
      when IfNode
        render_if(node, render_context)
      when ForNode
        render_for(node, render_context)
      else
        raise Error, "unknown node type: #{node.class}"
      end
    end

    def render_interpolation(name, filters, render_context)
      value = render_context.lookup(name)
      filters.each do |filter|
        value = apply_filter(filter, value)
      end

      HtmlEscape.escape(value)
    end

    def apply_filter(filter, value)
      Filters.apply(filter, value)
    end

    def render_if(node, render_context)
      return "" unless truthy?(render_context.lookup(node.condition))

      render_nodes(node.children, render_context)
    end

    def render_for(node, render_context)
      collection = render_context.lookup(node.collection)
      return "" if collection.nil?
      raise Error, "for collection must respond to each: #{node.collection}" unless collection.respond_to?(:each)

      output = +""

      collection.each do |value|
        output << render_nodes(node.children, render_context.with_locals(node.local_name => value))
      end

      output
    end

    def truthy?(value)
      !value.nil? && value != false
    end
  end
end

# frozen_string_literal: true

require_relative "errors"
require_relative "filters"
require_relative "helpers"
require_relative "html_escape"
require_relative "lexer"
require_relative "parser"
require_relative "render_context"

module Tpeg
  class Template
    def initialize(source, filters: {}, helpers: {}, loader: nil)
      @source = String(source)
      @filters = Filters.registry(filters)
      @helpers = Helpers.registry(helpers)
      @loader = loader
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
      when HelperNode
        render_helper(node, render_context)
      when IfNode
        render_if(node, render_context)
      when ForNode
        render_for(node, render_context)
      when PartialNode
        render_partial(node, render_context)
      else
        raise Error, "unknown node type: #{node.class}"
      end
    end

    def render_interpolation(name, filters, render_context)
      value = render_context.lookup(name)
      render_value(value, filters)
    end

    def render_helper(node, render_context)
      arguments = node.arguments.map { |argument| render_context.lookup(argument) }
      value = Helpers.call(node.name, arguments, @helpers)

      render_value(value, node.filters)
    end

    def render_value(value, filters)
      filters.each do |filter|
        value = apply_filter(filter, value)
      end

      HtmlEscape.escape(value)
    end

    def apply_filter(filter, value)
      Filters.apply(filter, value, @filters)
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

    def render_partial(node, render_context)
      raise Error, "loader is required to render partial: #{node.name}" if @loader.nil?

      source = @loader.load(node.name)
      partial_context = partial_render_context(node, render_context)

      render_nodes(Parser.new(Lexer.new(source).tokens).nodes, partial_context)
    end

    def partial_render_context(node, render_context)
      return render_context if node.value_path.nil?

      render_context.with_locals(node.local_name => render_context.lookup(node.value_path))
    end

    def truthy?(value)
      !value.nil? && value != false
    end
  end
end

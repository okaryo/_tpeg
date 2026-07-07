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
      @partial_nodes_by_name = {}
    end

    def render(context = {})
      render_context = RenderContext.new(context)
      render_nodes(nodes, render_context)
    end

    def nodes
      @nodes ||= Parser.new(Lexer.new(@source).tokens, source: @source).nodes
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
        render_interpolation(node, render_context)
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

    def render_interpolation(node, render_context)
      value = lookup_for_node(node.name, render_context, node)
      render_value(value, node.filters, node)
    end

    def lookup_for_node(name, render_context, node)
      render_context.lookup(name)
    rescue MissingVariable => error
      raise MissingVariable, "#{error.message} at line #{node.line}, column #{node.column}"
    end

    def render_helper(node, render_context)
      arguments = node.arguments.map { |argument| lookup_for_node(argument, render_context, node) }
      value = call_helper_for_node(node, arguments)

      render_value(value, node.filters, node)
    end

    def call_helper_for_node(node, arguments)
      Helpers.call(node.name, arguments, @helpers)
    rescue Error => error
      raise unless error.message == "unknown helper: #{node.name}"

      raise Error, "#{error.message} at line #{node.line}, column #{node.column}"
    end

    def render_value(value, filters, node)
      filters.each do |filter|
        value = apply_filter_for_node(filter, value, node)
      end

      HtmlEscape.escape(value)
    end

    def apply_filter_for_node(filter, value, node)
      Filters.apply(filter, value, @filters)
    rescue Error => error
      raise unless error.message == "unknown filter: #{filter}"

      raise Error, "#{error.message} at line #{node.line}, column #{node.column}"
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

      partial_context = partial_render_context(node, render_context)

      render_nodes(partial_nodes(node.name), partial_context)
    end

    def partial_nodes(name)
      return @partial_nodes_by_name[name] if @partial_nodes_by_name.key?(name)

      source = @loader.load(name)
      @partial_nodes_by_name[name] = Parser.new(Lexer.new(source).tokens, source: source).nodes
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

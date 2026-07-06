# frozen_string_literal: true

require "test_helper"

class TemplateTest < Minitest::Test
  def test_reuses_parsed_nodes_for_one_template_instance
    template = Tpeg::Template.new("Hello, {{ name }}!")

    assert_same template.nodes, template.nodes
  end

  def test_renders_same_template_instance_with_different_contexts
    template = Tpeg::Template.new("Hello, {{ name }}!")

    assert_equal "Hello, Ruby!", template.render({ name: "Ruby" })
    assert_equal "Hello, Go!", template.render({ name: "Go" })
  end

  def test_reuses_partial_nodes_for_one_template_instance
    loader = CountingLoader.new(greeting: "Hello, {{ name }}!")
    template = Tpeg::Template.new("{% render greeting %} {% render greeting %}", loader: loader)

    assert_equal "Hello, Ruby! Hello, Ruby!", template.render({ name: "Ruby" })
    assert_equal 1, loader.load_count_for("greeting")
  end

  class CountingLoader
    def initialize(templates)
      @loader = Tpeg::HashLoader.new(templates)
      @load_counts = Hash.new(0)
    end

    def load(name)
      @load_counts[name.to_s] += 1
      @loader.load(name)
    end

    def load_count_for(name)
      @load_counts[name.to_s]
    end
  end
end

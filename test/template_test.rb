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
end

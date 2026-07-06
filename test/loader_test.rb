# frozen_string_literal: true

require "test_helper"

class LoaderTest < Minitest::Test
  def test_loads_template_source_by_name
    loader = Tpeg::HashLoader.new("greeting" => "Hello, {{ name }}!")

    assert_equal "Hello, {{ name }}!", loader.load("greeting")
  end

  def test_converts_template_names_to_strings
    loader = Tpeg::HashLoader.new(greeting: "Hello")

    assert_equal "Hello", loader.load("greeting")
  end

  def test_converts_template_source_to_string
    loader = Tpeg::HashLoader.new(greeting: :hello)

    assert_equal "hello", loader.load("greeting")
  end

  def test_raises_for_missing_template
    loader = Tpeg::HashLoader.new({})

    error = assert_raises(Tpeg::Error) do
      loader.load("missing")
    end

    assert_equal "template not found: missing", error.message
  end

  def test_raises_for_invalid_templates
    error = assert_raises(Tpeg::Error) do
      Tpeg::HashLoader.new(Object.new)
    end

    assert_equal "templates must respond to each", error.message
  end
end

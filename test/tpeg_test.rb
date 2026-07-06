# frozen_string_literal: true

require "test_helper"

class TpegTest < Minitest::Test
  def test_renders_plain_text_unchanged
    assert_equal "hello", Tpeg.render("hello")
  end

  def test_interpolates_string_key
    assert_equal "Hello, Ruby!", Tpeg.render("Hello, {{ name }}!", { "name" => "Ruby" })
  end

  def test_interpolates_symbol_key
    assert_equal "Hello, Ruby!", Tpeg.render("Hello, {{ name }}!", { name: "Ruby" })
  end

  def test_interpolates_adjacent_markers
    assert_equal "ab", Tpeg.render("{{ a }}{{ b }}", { a: "a", b: "b" })
  end

  def test_converts_values_to_strings
    assert_equal "count: 3", Tpeg.render("count: {{ count }}", { count: 3 })
  end

  def test_interpolates_nested_hash_value
    assert_equal "Hello, Ruby!", Tpeg.render("Hello, {{ user.name }}!", { user: { name: "Ruby" } })
  end

  def test_escapes_interpolated_html
    assert_equal "&lt;strong&gt;Ruby&lt;/strong&gt;", Tpeg.render("{{ name }}", { name: "<strong>Ruby</strong>" })
  end

  def test_does_not_escape_plain_text
    assert_equal "<p>Ruby</p>", Tpeg.render("<p>Ruby</p>")
  end

  def test_renders_raw_value_without_escaping
    assert_equal "<strong>Ruby</strong>", Tpeg.render("{{ name }}", { name: Tpeg.raw("<strong>Ruby</strong>") })
  end

  def test_applies_upcase_filter_before_escaping
    assert_equal "RUBY", Tpeg.render("{{ name | upcase }}", { name: "Ruby" })
    assert_equal "&lt;B&gt;RUBY&lt;/B&gt;", Tpeg.render("{{ name | upcase }}", { name: "<b>Ruby</b>" })
  end

  def test_raises_for_unknown_filter
    error = assert_raises(Tpeg::Error) do
      Tpeg.render("{{ name | unknown }}", { name: "Ruby" })
    end

    assert_equal "unknown filter: unknown", error.message
  end

  def test_renders_with_custom_filter
    filters = {
      bracket: ->(value) { "[#{value}]" }
    }

    assert_equal "[Ruby]", Tpeg.render("{{ name | bracket }}", { name: "Ruby" }, filters: filters)
  end

  def test_applies_multiple_filters_from_left_to_right
    filters = {
      bracket: ->(value) { "[#{value}]" }
    }

    assert_equal "[RUBY]", Tpeg.render("{{ name | upcase | bracket }}", { name: "Ruby" }, filters: filters)
  end

  def test_renders_with_custom_helper
    helpers = {
      join: ->(left, right) { "#{left}:#{right}" }
    }

    assert_equal "Ruby:Go", Tpeg.render("{{ join(left, right) }}", { left: "Ruby", right: "Go" }, helpers: helpers)
  end

  def test_applies_filter_to_helper_result_before_escaping
    helpers = {
      join: ->(left, right) { "#{left}:#{right}" }
    }

    assert_equal "RUBY:GO", Tpeg.render("{{ join(left, right) | upcase }}", { left: "Ruby", right: "Go" }, helpers: helpers)
  end

  def test_raises_for_unknown_helper
    error = assert_raises(Tpeg::Error) do
      Tpeg.render("{{ join(left, right) }}", { left: "Ruby", right: "Go" })
    end

    assert_equal "unknown helper: join", error.message
  end

  def test_renders_if_block_when_condition_is_truthy
    assert_equal "Hello, Ruby!", Tpeg.render("Hello, {% if user %}{{ user.name }}{% end %}!", { user: { name: "Ruby" } })
  end

  def test_skips_if_block_when_condition_is_false
    assert_equal "Hello, !", Tpeg.render("Hello, {% if user %}{{ user.name }}{% end %}!", { user: false })
  end

  def test_skips_if_block_when_condition_is_nil
    assert_equal "Hello, !", Tpeg.render("Hello, {% if user %}{{ user.name }}{% end %}!", { user: nil })
  end

  def test_renders_nested_if_blocks
    template = "{% if user %}{% if user.active %}active{% end %}{% end %}"

    assert_equal "active", Tpeg.render(template, { user: { active: true } })
  end

  def test_renders_for_block_for_each_item
    template = "{% for item in items %}{{ item.name }} {% end %}"

    assert_equal "Ruby Go ", Tpeg.render(template, { items: [{ name: "Ruby" }, { name: "Go" }] })
  end

  def test_for_block_local_value_shadows_parent_value
    template = "{{ item.name }}:{% for item in items %}{{ item.name }}{% end %}:{{ item.name }}"

    assert_equal "Parent:Child:Parent", Tpeg.render(template, { item: { name: "Parent" }, items: [{ name: "Child" }] })
  end

  def test_renders_if_inside_for_block
    template = "{% for item in items %}{% if item.active %}{{ item.name }} {% end %}{% end %}"
    items = [{ name: "Ruby", active: true }, { name: "Go", active: false }]

    assert_equal "Ruby ", Tpeg.render(template, { items: items })
  end

  def test_renders_nested_for_blocks_with_parent_and_local_values
    template = "{% for item in items %}{% for book in books %}{{ item.name }}:{{ book.title }};{% end %}{% end %}"
    context = {
      items: [{ name: "Ruby" }, { name: "Go" }],
      books: [{ title: "Book A" }, { title: "Book B" }]
    }

    assert_equal "Ruby:Book A;Ruby:Book B;Go:Book A;Go:Book B;", Tpeg.render(template, context)
  end

  def test_renders_partial_with_current_context
    loader = Tpeg::HashLoader.new(greeting: "Hello, {{ name }}!")

    assert_equal "Before Hello, Ruby! After", Tpeg.render("Before {% render greeting %} After", { name: "Ruby" }, loader: loader)
  end

  def test_renders_partial_with_current_loop_context
    loader = Tpeg::HashLoader.new(item: "{{ item.name }};")
    template = "{% for item in items %}{% render item %}{% end %}"

    assert_equal "Ruby;Go;", Tpeg.render(template, { items: [{ name: "Ruby" }, { name: "Go" }] }, loader: loader)
  end

  def test_renders_partial_with_explicit_value
    loader = Tpeg::HashLoader.new(card: "{{ card.name }}")
    context = { user: { name: "Ruby" } }

    assert_equal "Ruby", Tpeg.render("{% render card with user %}", context, loader: loader)
  end

  def test_partial_explicit_value_shadows_parent_value
    loader = Tpeg::HashLoader.new(card: "{{ card.name }}")
    context = {
      card: { name: "Parent" },
      user: { name: "Ruby" }
    }

    assert_equal "Ruby", Tpeg.render("{% render card with user %}", context, loader: loader)
  end

  def test_renders_partial_with_explicit_local_name
    loader = Tpeg::HashLoader.new(card: "{{ profile.name }}")
    context = { user: { name: "Ruby" } }

    assert_equal "Ruby", Tpeg.render("{% render card with user as profile %}", context, loader: loader)
  end

  def test_raises_when_rendering_partial_without_loader
    error = assert_raises(Tpeg::Error) do
      Tpeg.render("{% render greeting %}")
    end

    assert_equal "loader is required to render partial: greeting", error.message
  end

  def test_raises_when_for_collection_is_not_iterable
    error = assert_raises(Tpeg::Error) do
      Tpeg.render("{% for item in items %}{{ item }}{% end %}", { items: 1 })
    end

    assert_equal "for collection must respond to each: items", error.message
  end

  def test_raises_for_missing_variable
    error = assert_raises(Tpeg::MissingVariable) do
      Tpeg.render("Hello, {{ name }}!")
    end

    assert_equal "missing variable: name", error.message
  end

  def test_raises_for_unterminated_interpolation
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg.render("Hello, {{ name")
    end

    assert_equal "unterminated interpolation at line 1, column 8\nHello, {{ name\n       ^", error.message
  end

  def test_raises_for_unexpected_closing_delimiter
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg.render("Hello }}")
    end

    assert_equal "unexpected closing delimiter at line 1, column 7\nHello }}\n      ^", error.message
  end

  def test_raises_for_empty_interpolation
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg.render("Hello, {{ }}!")
    end

    assert_equal "empty interpolation at line 1, column 11\nHello, {{ }}!\n          ^", error.message
  end

  def test_raises_for_invalid_variable_name
    error = assert_raises(Tpeg::SyntaxError) do
      Tpeg.render("Hello, {{ user..name }}!", { user: { name: "Ruby" } })
    end

    assert_equal "invalid variable name: \"user..name\" at line 1, column 11\nHello, {{ user..name }}!\n          ^", error.message
  end

  def test_raises_for_invalid_context
    error = assert_raises(Tpeg::InvalidContext) do
      Tpeg.render("Hello, {{ name }}!", Object.new)
    end

    assert_equal "render context must respond to key? and []", error.message
  end
end

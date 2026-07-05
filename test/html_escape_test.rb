# frozen_string_literal: true

require "test_helper"

class HtmlEscapeTest < Minitest::Test
  def test_escapes_html_special_characters
    assert_equal "&lt;script&gt;&amp;&quot;&#39;", Tpeg::HtmlEscape.escape(%(<script>&"'))
  end

  def test_converts_non_string_values
    assert_equal "3", Tpeg::HtmlEscape.escape(3)
  end

  def test_does_not_escape_html_safe_string
    assert_equal "<strong>Ruby</strong>", Tpeg::HtmlEscape.escape(Tpeg.raw("<strong>Ruby</strong>"))
  end

  def test_does_not_escape_already_escaped_safe_string_again
    assert_equal "&lt;strong&gt;Ruby&lt;/strong&gt;", Tpeg::HtmlEscape.escape(Tpeg.raw("&lt;strong&gt;Ruby&lt;/strong&gt;"))
  end

  def test_escapes_plain_string_even_when_it_looks_escaped
    assert_equal "&amp;lt;strong&amp;gt;Ruby&amp;lt;/strong&amp;gt;", Tpeg::HtmlEscape.escape("&lt;strong&gt;Ruby&lt;/strong&gt;")
  end
end

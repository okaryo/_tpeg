# frozen_string_literal: true

require "test_helper"

class HtmlEscapeTest < Minitest::Test
  def test_escapes_html_special_characters
    assert_equal "&lt;script&gt;&amp;&quot;&#39;", Tpeg::HtmlEscape.escape(%(<script>&"'))
  end

  def test_converts_non_string_values
    assert_equal "3", Tpeg::HtmlEscape.escape(3)
  end
end

# Escaping

Interpolated values are HTML-escaped by default.

For example:

```ruby
Tpeg.render("{{ name }}", name: "<strong>Ruby</strong>")
```

renders:

```text
&lt;strong&gt;Ruby&lt;/strong&gt;
```

Only values read from the render context are escaped. Plain text written in the
template source is preserved as-is.

Use `Tpeg.raw(value)` to mark a value as already safe for HTML output:

```ruby
Tpeg.render("{{ name }}", name: Tpeg.raw("<strong>Ruby</strong>"))
```

This renders the raw HTML string without escaping it. `Tpeg.raw` is an explicit
API, not template syntax.

`Tpeg.raw` is also the current double-escaping escape hatch. Plain strings are
always escaped, even if they already contain entities such as `&lt;`. The engine
does not try to guess whether an ordinary string is already safe HTML.

## Current Scope

Escaping uses Ruby's standard `CGI.escapeHTML`.

Compared with Ruby's standard `ERB::Util.html_escape`, the current escaping
output matches for the basic HTML-sensitive characters checked so far:

```text
< > & " '
```

Both `ERB::Util.html_escape` and `Tpeg::HtmlEscape.escape` also escape a plain
string that already contains entities such as `&lt;`. In `_tpeg`, avoiding that
double escaping requires the explicit `Tpeg.raw` API.

The current implementation does not support:

- Raw output syntax.
- Automatic safe-string detection.
- Context-aware escaping for JavaScript, CSS, URLs, or HTML attributes.

Those behaviors should be introduced as separate learning steps.

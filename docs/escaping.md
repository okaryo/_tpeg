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

## Current Scope

Escaping uses Ruby's standard `CGI.escapeHTML`.

The current implementation does not support:

- Raw output syntax.
- Safe string markers.
- Avoiding double escaping.
- Context-aware escaping for JavaScript, CSS, URLs, or HTML attributes.

Those behaviors should be introduced as separate learning steps.

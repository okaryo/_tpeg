# Filters

Filters are value transformations inside interpolation expressions.

Current syntax:

```text
{{ name | upcase }}
{{ name | upcase | bracket }}
```

The parser splits the interpolation expression into:

- a variable path: `name`
- a list of filters: `["upcase"]`

The renderer resolves the variable path through `RenderContext`, applies each
filter through `Tpeg::Filters` from left to right, then HTML-escapes the final
value.

```text
lookup -> filter -> filter -> escaping -> output
```

This order means filters operate on the original Ruby value, and escaping remains
the final output-safety step.

## Current Scope

Only one built-in filter exists:

- `upcase`: converts the value to a string and calls `upcase`.

Custom filters can be passed per render call:

```ruby
filters = {
  bracket: ->(value) { "[#{value}]" }
}

Tpeg.render("{{ name | bracket }}", { name: "Ruby" }, filters: filters)
# => "[Ruby]"

Tpeg.render("{{ name | upcase | bracket }}", { name: "Ruby" }, filters: filters)
# => "[RUBY]"
```

Custom filter names are converted to strings, so symbol keys and string keys
both work. A custom filter must respond to `call`.

Unknown filter names are render errors, not parser errors. The parser only checks
that a filter name has a valid identifier shape. This keeps syntax validation
separate from runtime filter lookup.

Built-in filters currently live in `Tpeg::Filters::BUILT_INS`. Per-render custom
filters are merged with those built-ins for that render only.

Helpers use a separate `helpers:` registry because they call named operations
with arguments, while filters transform a single value already being rendered.

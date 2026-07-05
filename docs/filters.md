# Filters

Filters are value transformations inside interpolation expressions.

Current syntax:

```text
{{ name | upcase }}
```

The parser splits the interpolation expression into:

- a variable path: `name`
- a list of filters: `["upcase"]`

The renderer resolves the variable path through `RenderContext`, applies each
filter through `Tpeg::Filters`, then HTML-escapes the final value.

```text
lookup -> filters -> escaping -> output
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
```

Custom filter names are converted to strings, so symbol keys and string keys
both work. A custom filter must respond to `call`.

Unknown filter names are render errors, not parser errors. The parser only checks
that a filter name has a valid identifier shape. This keeps syntax validation
separate from runtime filter lookup.

Built-in filters currently live in `Tpeg::Filters::BUILT_INS`. Per-render custom
filters are merged with those built-ins for that render only.

There is no helper registration API yet. That is a separate design step because
helpers raise broader questions about arguments, return safety, and how much Ruby
behavior should be exposed to templates.

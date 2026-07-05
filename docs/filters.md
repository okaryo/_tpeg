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

Unknown filter names are render errors, not parser errors. The parser only checks
that a filter name has a valid identifier shape. This keeps syntax validation
separate from runtime filter lookup.

Built-in filters currently live in `Tpeg::Filters::BUILT_INS`. This is still a
fixed registry, not a public registration API.

There is no helper registration API yet. That is a separate design step because
it raises questions about where helper functions live, how they are passed into a
template, and how helper errors should be reported.

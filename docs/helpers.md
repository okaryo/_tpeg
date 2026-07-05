# Helpers

Helpers are callable functions exposed to templates by the host Ruby code.

They are more general than filters:

- a filter transforms one interpolated value: `{{ name | upcase }}`
- a helper performs an explicitly named operation, usually with one or more
  arguments

## Registration Direction

Helpers should be registered per render call, similar to custom filters.

Planned shape:

```ruby
helpers = {
  link_to: ->(label, href) { %(<a href="#{href}">#{label}</a>) }
}

Tpeg.render(source, context, helpers: helpers)
```

This keeps helper availability local to one render operation. It also avoids a
global mutable helper registry that could affect unrelated templates.

## Safety Boundary

Helpers should be explicit. The template language should not fall back to Ruby's
normal method lookup and should not allow arbitrary method calls such as
`File.read`, `system`, or `exec`.

That means helper support should be implemented as:

```text
parse helper expression -> look up registered helper -> call it
```

not as:

```text
evaluate arbitrary Ruby code
```

This is the key difference from ERB-style rendering, where templates are Ruby
code evaluated in a view context.

## Open Syntax Decision

The exact helper call syntax is still undecided. The next implementation step
should choose a small syntax that is easy to parse and explain before adding
general argument handling.

Possible directions:

- function-like syntax: `{{ link_to(name, url) }}`
- tag-like syntax: `{% helper link_to name url %}`

The first version should support only variable-path arguments. Literal strings,
keyword arguments, blocks, and HTML-safety rules can be explored later.

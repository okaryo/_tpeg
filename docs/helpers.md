# Helpers

Helpers are callable functions exposed to templates by the host Ruby code.

They are more general than filters:

- a filter transforms one interpolated value: `{{ name | upcase }}`
- a helper performs an explicitly named operation, usually with one or more
  arguments

## Registration Direction

Helpers are registered per render call, similar to custom filters.

Current shape:

```ruby
helpers = {
  join: ->(left, right) { "#{left}:#{right}" }
}

Tpeg.render("{{ join(first, second) }}", { first: "Ruby", second: "Go" }, helpers: helpers)
# => "Ruby:Go"
```

This keeps helper availability local to one render operation. It also avoids a
global mutable helper registry that could affect unrelated templates.

## Safety Boundary

Helpers should be explicit. The template language should not fall back to Ruby's
normal method lookup and should not allow arbitrary method calls such as
`File.read`, `system`, or `exec`.

Helper support is implemented as:

```text
parse helper expression -> look up registered helper -> call it
```

not as:

```text
evaluate arbitrary Ruby code
```

This is the key difference from ERB-style rendering, where templates are Ruby
code evaluated in a view context.

## Current Syntax

The first helper syntax is function-like interpolation:

```text
{{ helper_name(argument.path, other.path) }}
```

Arguments are variable paths resolved through `RenderContext`. Literal strings,
keyword arguments, nested helper calls, blocks, and arbitrary Ruby expressions
are not supported.

The helper result follows the same output path as variable interpolation:

```text
helper result -> filters -> escaping -> output
```

So this is valid:

```text
{{ join(first, second) | upcase }}
```

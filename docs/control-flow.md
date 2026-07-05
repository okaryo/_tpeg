# Control Flow

Control tags use `{% ... %}` delimiters.

The current supported block is:

```text
{% if user %}
  Hello, {{ user.name }}!
{% end %}
```

The parser turns this into an `IfNode` with child nodes between the opening
`if` tag and the matching `end` tag.

The parser also recognizes loop blocks:

```text
{% for item in items %}
  {{ item.name }}
{% end %}
```

This becomes a `ForNode` with a local variable name, a collection variable path,
and child nodes. Rendering `ForNode` values is not implemented yet.

## Truthiness

`if` conditions use Ruby-like truthiness:

- `nil` is falsey.
- `false` is falsey.
- Every other value is truthy, including empty strings, empty arrays, empty
  hashes, and zero.

The condition is a variable path resolved through `RenderContext`, so
`{% if user.active %}` performs the same hash-like nested lookup as
`{{ user.active }}`.

## Current Scope

The current implementation supports nested `if` blocks.
The parser supports nested `for` blocks, but rendering loops is still pending.

It does not support:

- `else` or `elsif`.
- Boolean expressions such as `and`, `or`, or `not`.
- Comparisons.
- Calling Ruby methods from conditions.

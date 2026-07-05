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

It does not support:

- `else` or `elsif`.
- Boolean expressions such as `and`, `or`, or `not`.
- Comparisons.
- Loops.
- Calling Ruby methods from conditions.

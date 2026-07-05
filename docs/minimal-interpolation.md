# Minimal Interpolation

The first implementation step keeps the template language intentionally small.

Supported syntax:

```text
Hello, {{ name }}!
```

Rendering uses a hash-like context. Keys may be strings or symbols:

```ruby
Tpeg.render("Hello, {{ name }}!", { name: "Ruby" })
```

This returns:

```text
Hello, Ruby!
```

## Current Lifecycle

The current renderer does not have a separate lexer, parser, or AST yet. It
uses `StringScanner` to walk through the source string from left to right:

1. Copy plain text characters to the output.
2. When `{{` appears, read until the next `}}`.
3. Treat the trimmed contents as a variable name.
4. Look up the variable in the render context.
5. Append the value converted with `to_s`.

This is deliberately direct. It makes the smallest source-to-output lifecycle
visible before adding lexer and parser boundaries.

## Decisions

- Missing variables raise `Tpeg::MissingVariable`.
- Unterminated `{{` markers raise `Tpeg::SyntaxError`.
- Unexpected `}}` markers raise `Tpeg::SyntaxError`.
- Empty interpolation markers raise `Tpeg::SyntaxError`.
- Variable names currently allow only simple identifiers such as `name`,
  `user_name`, and `item2`.

Raising on missing variables keeps mistakes visible while the engine is small.
Returning an empty string can be explored later if the learning goal shifts
toward Mustache-like behavior.

## Boundaries

The first step intentionally does not support:

- Nested lookup such as `user.name`.
- Expressions.
- Conditionals or loops.
- HTML escaping.
- Raw output.
- Partials, layouts, loading, compilation, or caching.

The next useful boundary is a lexer that emits explicit text and interpolation
tokens with source positions.

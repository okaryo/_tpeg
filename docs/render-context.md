# Render Context

The render context is responsible for resolving variable names during rendering.

Current lookup behavior:

1. Look for a string key matching the variable name.
2. If no string key exists, look for a symbol key.
3. If neither key exists, raise `Tpeg::MissingVariable`.

For example, `{{ name }}` can read either `"name"` or `:name` from a hash-like
context.

If both keys exist, the string key wins. This keeps lookup deterministic while
still accepting the common Ruby hash styles.

Dot-separated names perform nested lookup through hash-like values. For
example, `{{ user.name }}` first resolves `user`, then resolves `name` inside
that value. Each path segment uses the same string-key-then-symbol-key behavior.
Arbitrary Ruby method calls are not used.

`RenderContext#with_locals` creates a child context. Lookup checks the child
scope first, then falls back to the parent scope when the top-level key is not
defined locally. A local top-level key shadows the same parent key.

## Current Scope

The render context currently expects a hash-like object that responds to
`key?` and `[]`. Passing any other object raises `Tpeg::InvalidContext`.

The context is shallow-copied when `RenderContext` is initialized. This keeps
later changes to the top-level input hash from changing lookup behavior during
rendering. Nested values are not deep-copied.

It does not support:

- Calling methods on arbitrary Ruby objects.
- Deep-copying nested context data.

Those behaviors should be introduced only when the template language needs
them.

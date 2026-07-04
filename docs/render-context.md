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

## Current Scope

The render context currently expects a hash-like object that responds to
`key?` and `[]`.

It does not support:

- Nested lookup such as `user.name`.
- Calling methods on arbitrary Ruby objects.
- Scoped lookup for loops or partials.
- Mutation of context data.

Those behaviors should be introduced only when the template language needs
them.

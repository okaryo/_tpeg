# Parser

The parser is the first boundary above lexer tokens.

Current node types:

- `TextNode`: plain text to copy into output later.
- `VariableNode`: a variable lookup requested by an interpolation marker.
- `IfNode`: a conditional block with a variable-path condition and child nodes.
- `ForNode`: a loop block with a local variable name, collection path, and
  child nodes.

For simple tokens, the parser maps token types to node types:

- `:text` token -> `TextNode`
- `:interpolation` token -> `VariableNode`
- supported `:tag` token -> `IfNode` or `ForNode`

Source positions are copied from tokens to nodes. This keeps later diagnostics
able to point at the parsed value rather than re-reading the source.

`{% if user %}...{% end %}` is parsed into an `IfNode`. The parser consumes
tokens until the matching `end` tag and stores the nested content as child
nodes. Nested `if` blocks are parsed recursively.
`{% for item in items %}...{% end %}` is parsed into a `ForNode` in the same
way.

## Current Scope

The parser validates variable names before creating `VariableNode` values.
Empty interpolation markers and invalid names are parsing errors. Context lookup
still happens in the renderer, so missing variables remain rendering errors.
Unknown tag contents are parsing errors because the parser is the component that
decides which control-flow syntax this engine supports. Invalid `for` tag syntax
is also a parsing error.

The renderer consumes parser nodes, so the current flow is:

```text
source -> lexer tokens -> parser nodes -> rendered output
```

This keeps source scanning and template representation separate from rendering
context lookup.

## Next Boundary

Useful next steps are:

- Add another supported tag intentionally, such as `else`.

# Parser

The parser is the first boundary above lexer tokens.

Current node types:

- `TextNode`: plain text to copy into output later.
- `VariableNode`: a variable lookup requested by an interpolation marker.
- `TagNode`: raw control tag content requested by a `{% ... %}` marker.
- `IfNode`: a conditional block with a variable-path condition and child nodes.
- `ForNode`: a loop block with a local variable name, collection path, and
  child nodes.

For now, the parser only maps token types to node types:

- `:text` token -> `TextNode`
- `:interpolation` token -> `VariableNode`
- `:tag` token -> `TagNode`

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
Unknown tag contents are kept as `TagNode` values for now. Invalid `for` tag
syntax is a parsing error.

The renderer consumes parser nodes, so the current flow is:

```text
source -> lexer tokens -> parser nodes -> rendered output
```

This keeps source scanning and template representation separate from rendering
context lookup.

## Next Boundary

Useful next steps are:

- Render `ForNode` values using child render contexts.

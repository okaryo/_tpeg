# Parser

The parser is the first boundary above lexer tokens.

Current node types:

- `TextNode`: plain text to copy into output later.
- `VariableNode`: a variable lookup requested by an interpolation marker,
  plus any filters applied to the looked-up value.
- `HelperNode`: an explicit helper call requested by an interpolation marker,
  plus argument variable paths and filters.
- `IfNode`: a conditional block with a variable-path condition and child nodes.
- `ForNode`: a loop block with a local variable name, collection path, and
  child nodes.
- `PartialNode`: a request to load and render another template by name.

For simple tokens, the parser maps token types to node types:

- `:text` token -> `TextNode`
- `:interpolation` token -> `VariableNode` or `HelperNode` with filters
- supported `:tag` token -> `IfNode`, `ForNode`, or `PartialNode`

Source positions are copied from tokens to nodes. This keeps later diagnostics
able to point at the parsed value rather than re-reading the source.

`{% if user %}...{% end %}` is parsed into an `IfNode`. The parser consumes
tokens until the matching `end` tag and stores the nested content as child
nodes. Nested `if` blocks are parsed recursively.
`{% for item in items %}...{% end %}` is parsed into a `ForNode` in the same
way.
`{% render greeting %}` is parsed into a `PartialNode` that keeps the template
name for the renderer. `{% render card with user %}` also stores the value path
that should be passed into the partial. `{% render card with user as profile %}`
also stores the explicit local name.

## Current Scope

The parser validates interpolation expressions before creating `VariableNode` or
`HelperNode` values. Empty interpolation markers, invalid variable names, invalid
helper arguments, and invalid filter names are parsing errors. Context lookup and
helper lookup still happen in the renderer, so missing variables and unknown
helpers remain rendering errors.
Unknown tag contents are parsing errors because the parser is the component that
decides which tag syntax this engine supports. Invalid `for` and `render` tag
syntax are also parsing errors.

The renderer consumes parser nodes, so the current flow is:

```text
source -> lexer tokens -> parser nodes -> rendered output
```

This keeps source scanning and template representation separate from rendering
context lookup.

## Next Boundary

Useful next steps are:

- Add explicit partial arguments or context isolation.

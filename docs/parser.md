# Parser

The parser is the first boundary above lexer tokens.

Current node types:

- `TextNode`: plain text to copy into output later.
- `VariableNode`: a variable lookup requested by an interpolation marker.

For now, the parser only maps token types to node types:

- `:text` token -> `TextNode`
- `:interpolation` token -> `VariableNode`

Source positions are copied from tokens to nodes. This keeps later diagnostics
able to point at the parsed value rather than re-reading the source.

## Current Scope

The parser does not validate variable names yet. A token such as an empty
interpolation still becomes a `VariableNode` with an empty name. Name validation
and context lookup still happen in the renderer until the expression grammar is
clearer.

The renderer does not consume parser nodes yet. This step only introduces the
template representation boundary.

## Next Boundary

Useful next steps are:

- Move the renderer from lexer tokens to parser nodes.
- Decide whether variable name validation belongs in the parser.

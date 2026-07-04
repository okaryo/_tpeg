# Lexer

The lexer is the first boundary between the raw template source and later
rendering behavior.

Current token types:

- `:text`: plain source text outside template delimiters.
- `:interpolation`: source text between `{{` and `}}`.

Each token carries:

- `start_offset`: zero-based byte offset where the token value starts.
- `end_offset`: zero-based byte offset just after the token value.
- `line`: one-based line number where the token value starts.
- `column`: one-based column number where the token value starts.

Interpolation token values trim surrounding whitespace inside the delimiters.
For example, `{{ name }}` produces an interpolation token with the value `name`.
The token position points at the trimmed value, not at the opening delimiter.
Validating the expression still belongs to the renderer in the current
implementation.

## Current Scope

The renderer consumes lexer tokens, so source scanning is centralized in the
lexer. Expression validation and context lookup still belong to the renderer
until a parser or template representation is introduced.

The lexer does detect delimiter-level syntax errors:

- `{{` without a matching `}}` raises `Tpeg::SyntaxError`.
- `}}` before any matching `{{` raises `Tpeg::SyntaxError`.

## Next Boundary

Useful next steps are:

- Introduce a parser or template representation above lexer tokens.

# Lexer

The lexer is the first boundary between the raw template source and later
rendering behavior.

Current token types:

- `:text`: plain source text outside template delimiters.
- `:interpolation`: source text between `{{` and `}}`.
- `:tag`: control tag text between `{%` and `%}`.

Each token carries:

- `start_offset`: zero-based byte offset where the token value starts.
- `end_offset`: zero-based byte offset just after the token value.
- `line`: one-based line number where the token value starts.
- `column`: one-based column number where the token value starts.

Interpolation and tag token values trim surrounding whitespace inside the delimiters.
For example, `{{ name }}` produces an interpolation token with the value `name`.
The token position points at the trimmed value, not at the opening delimiter.
Validating expressions and tag contents belongs to parser-level steps.

## Current Scope

The lexer only identifies source regions and delimiter-level errors. Parser and
renderer steps decide what interpolation values and control tags mean.

The lexer does detect delimiter-level syntax errors:

- `{{` without a matching `}}` raises `Tpeg::SyntaxError`.
- `}}` before any matching `{{` raises `Tpeg::SyntaxError`.
- `{%` without a matching `%}` raises `Tpeg::SyntaxError`.
- `%}` before any matching `{%` raises `Tpeg::SyntaxError`.

## Next Boundary

Useful next steps are:

- Parse control tags into conditional block nodes.

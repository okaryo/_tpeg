# Lexer

The lexer is the first boundary between the raw template source and later
rendering behavior.

Current token types:

- `:text`: plain source text outside template delimiters.
- `:interpolation`: source text between `{{` and `}}`.

For now, interpolation token values keep the inner whitespace unchanged. For
example, `{{ name }}` produces an interpolation token with the value ` name `.
Trimming and validating the expression still belongs to the renderer in the
current implementation.

## Current Scope

This step only introduces tokenization. The existing renderer still scans the
source directly, so rendering behavior is unchanged.

The lexer does detect delimiter-level syntax errors:

- `{{` without a matching `}}` raises `Tpeg::SyntaxError`.
- `}}` before any matching `{{` raises `Tpeg::SyntaxError`.

## Next Boundary

Useful next steps are:

- Add source positions to tokens.
- Move the renderer from direct source scanning to lexer tokens.
- Decide where interpolation whitespace trimming should live.

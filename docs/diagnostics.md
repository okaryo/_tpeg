# Diagnostics

Diagnostics are the information attached to template errors so the template
author can find and fix the problem.

## Current Scope

Parser errors now include token source location when the parser can associate
the error with a lexer token:

```text
unknown tag: "unknown user" at line 1, column 10
invalid variable name: "user..name" at line 1, column 11
```

This currently applies to:

- unexpected `end` tags
- unknown token types
- unknown tags
- invalid `for` tags
- invalid `render` tags
- empty interpolation markers
- invalid variable names
- invalid filter names
- invalid helper arguments

The parser uses token metadata from the lexer:

```text
source -> lexer token(line, column) -> parser error
```

## Remaining Gaps

Not all errors include source locations yet. Unterminated block errors currently
know the block type, but they do not point back to the opening block location.
Lexer delimiter errors also do not include a source snippet yet.

Useful next improvements:

- include source snippets and a caret marker
- distinguish opening block locations from closing or missing block errors
- add render-time locations for missing variables, unknown helpers, and unknown
  filters

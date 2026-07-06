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
- unterminated `if` and `for` blocks, reported at the opening block tag

The parser uses token metadata from the lexer:

```text
source -> lexer token(line, column) -> parser error
```

## Remaining Gaps

Not all errors include source locations yet. Lexer delimiter errors do not
include a source snippet yet, and render-time errors still report only the
runtime value path or helper/filter name.

Useful next improvements:

- include source snippets and a caret marker
- add render-time locations for missing variables, unknown helpers, and unknown
  filters

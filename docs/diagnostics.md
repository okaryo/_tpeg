# Diagnostics

Diagnostics are the information attached to template errors so the template
author can find and fix the problem.

## Current Scope

Some parser errors now include token source location:

```text
unknown tag: "unknown user" at line 1, column 10
```

This currently applies to errors that are directly tied to a lexer token, such
as:

- unexpected `end` tags
- unknown token types
- unknown tags
- invalid `for` tags
- invalid `render` tags

The parser uses token metadata from the lexer:

```text
source -> lexer token(line, column) -> parser error
```

## Remaining Gaps

Not all errors include source locations yet. For example, variable-name
validation errors and some interpolation expression errors still report only the
invalid value.

Useful next improvements:

- carry token information into variable/filter/helper validation
- include source snippets and a caret marker
- distinguish opening block locations from closing or missing block errors
- add render-time locations for missing variables, unknown helpers, and unknown
  filters

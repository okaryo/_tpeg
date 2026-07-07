# Diagnostics

Diagnostics are the information attached to template errors so the template
author can find and fix the problem.

## Current Scope

Parser errors now include token source location when the parser can associate
the error with a lexer token:

```text
unknown tag: "unknown user" at line 1, column 10
Hello {% unknown user %}!
         ^
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

Lexer delimiter errors use the same source line and caret marker format:

```text
unterminated interpolation at line 1, column 8
Hello, {{ name
       ^
```

## Remaining Gaps

Render-time errors still report only the runtime value path or helper/filter
name in some cases.

Missing variables requested by interpolation include the node location:

```text
missing variable: name at line 1, column 11
```

Missing variables requested as helper arguments include the helper node
location:

```text
missing variable: right at line 1, column 4
```

Missing variables requested by `if` conditions include the `if` node location:

```text
missing variable: user at line 1, column 11
```

Missing variables requested by `for` collections include the `for` node
location:

```text
missing variable: items at line 1, column 11
```

Unknown helpers and filters also include the interpolation node location:

```text
unknown helper: join at line 1, column 4
unknown filter: unknown at line 1, column 4
```

Useful next improvements:

- add render-time locations for missing variables used by partial arguments

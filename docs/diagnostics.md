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

## Render-Time Locations

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

Missing variables requested by partial `with` values include the render node
location:

```text
missing variable: user at line 1, column 11
```

Unknown helpers and filters also include the interpolation node location:

```text
unknown helper: join at line 1, column 4
unknown filter: unknown at line 1, column 4
```

## Known Diagnostic Limitations

The current block closing syntax is a generic `{% end %}` tag. This keeps the
parser small, but it also means the parser cannot distinguish an `if` end from a
`for` end. It can report unexpected or missing `end` tags, but it cannot report
a typed mismatch such as "expected endfor but found endif" because those tags do
not exist in the language yet.

Render-time locations point to the AST node that requested the lookup or call.
For helper arguments and partial `with` values, the location is the whole helper
or render tag, not the exact argument span.

Parser and lexer snippets show one source line with a caret. Multi-line spans,
include stacks for partials, and nested render traces are not tracked yet.

Useful next improvements:

- split broad render errors into more specific error classes
- add typed block endings if studying block mismatch diagnostics becomes useful
- add render-time source snippets or partial include stacks

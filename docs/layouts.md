# Layouts

Layouts wrap rendered page content in an outer template.

Conceptually, a layout render looks like this:

```text
page template -> rendered content -> layout template -> final output
```

For example, a page might produce:

```html
<h1>Hello</h1>
```

and a layout might place that content inside:

```html
<html>
  <body>{{ content }}</body>
</html>
```

## Current Decision

Layout rendering is deferred for now.

The project already has enough reuse mechanisms to study before adding another
rendering layer:

- helpers: explicit callable behavior
- filters: value transformations
- partials: named template reuse through a loader
- partial locals: scoped values passed into a loaded template

Layouts would introduce another source of render context and output-safety
questions. For example:

- Should layout content be raw HTML or escaped text?
- Is the content value stored in the same `RenderContext` or a child context?
- Does a layout use the same loader as partials?
- Should layout rendering happen inside `Tpeg.render` or in a separate API?

Those questions are useful, but they fit better after studying compilation,
caching, and diagnostics. The current project direction should move to direct
AST interpretation versus compiled/cached templates before implementing layouts.

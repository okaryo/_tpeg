# Compilation And Caching

The current renderer interprets parser nodes directly.

```text
source -> lexer -> parser -> nodes -> renderer walks nodes
```

This is different from an ERB-style approach that generates Ruby code and then
executes that generated code.

## Current Cache

`Tpeg::Template` now memoizes its parsed nodes:

```ruby
template = Tpeg::Template.new("Hello, {{ name }}!")

template.render({ name: "Ruby" })
template.render({ name: "Go" })
```

The first render parses the source into nodes. Later renders of the same
`Template` instance reuse those nodes and only redo context lookup and rendering.

This is an object-local cache:

- it does not share parsed nodes across different `Template` instances
- it does not cache templates loaded through `Tpeg::HashLoader`
- it does not generate Ruby code
- it does not solve file invalidation

## Direct Interpretation Versus Generated Ruby

Direct interpretation is easier to inspect:

- nodes stay as Ruby objects
- errors can be tied back to node source positions
- behavior is straightforward to step through in tests

Generated Ruby can be faster for repeated renders because the render path can
become ordinary Ruby instructions, but it introduces new concerns:

- generated source must be debugged
- source positions need mapping back to templates
- arbitrary Ruby generation can expand the safety surface
- caching and invalidation become more important

For this project, direct interpretation remains the default until there is a
clear learning reason to generate Ruby.

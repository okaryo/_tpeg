# Loaders

Loaders resolve a template name to template source.

They are the boundary used by partial rendering:

```text
template name -> loader -> template source
```

## Current Loader

`Tpeg::HashLoader` stores template source in a hash-like object.

```ruby
loader = Tpeg::HashLoader.new(
  "greeting" => "Hello, {{ name }}!"
)

loader.load("greeting")
# => "Hello, {{ name }}!"
```

Template names are converted to strings, so symbol keys and string keys both
work:

```ruby
loader = Tpeg::HashLoader.new(greeting: "Hello")
loader.load("greeting")
# => "Hello"
```

Missing templates are `Tpeg::Error` values:

```text
template not found: greeting
```

## Current Scope

The loader itself does not render templates. It only returns source text.

This keeps three responsibilities separate:

- loader: find source by name
- parser: turn source into nodes
- renderer: render nodes with context

Partial rendering uses the loader through the `{% render name %}` tag:

```ruby
loader = Tpeg::HashLoader.new(
  greeting: "Hello, {{ name }}!"
)

Tpeg.render("{% render greeting %}", { name: "Ruby" }, loader: loader)
# => "Hello, Ruby!"
```

The first partial implementation inherits the current render context. That means
a partial can read the same top-level values as the caller, and a partial inside
a loop can read the current loop local.

File-backed loading, path normalization, extension handling, caching, explicit
partial arguments, and context isolation are intentionally left for later steps.

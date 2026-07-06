# Loaders

Loaders resolve a template name to template source.

They are the boundary needed before partial rendering:

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

The loader does not render templates yet. It only returns source text.

This keeps three responsibilities separate:

- loader: find source by name
- parser: turn source into nodes
- renderer: render nodes with context

File-backed loading, path normalization, extension handling, caching, and partial
rendering are intentionally left for later steps.

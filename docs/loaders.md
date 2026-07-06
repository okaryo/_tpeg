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

Partials can also receive one explicit value:

```ruby
loader = Tpeg::HashLoader.new(
  card: "{{ card.name }}"
)

Tpeg.render("{% render card with user %}", { user: { name: "Ruby" } }, loader: loader)
# => "Ruby"
```

`with` resolves the right-hand side through the current `RenderContext` and
stores it as a partial-local value using the partial name. In the example above,
`user` is passed into the partial as `card`.

The local name can also be explicit:

```ruby
loader = Tpeg::HashLoader.new(
  card: "{{ profile.name }}"
)

Tpeg.render("{% render card with user as profile %}", { user: { name: "Ruby" } }, loader: loader)
# => "Ruby"
```

`as` only changes the local name inside the partial; it does not change which
template is loaded.

File-backed loading, path normalization, extension handling, caching, explicit
multiple partial arguments, and context isolation are intentionally left for
later steps.

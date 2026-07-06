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
- it does not generate Ruby code
- it does not solve file invalidation

Partial templates loaded through a loader are also memoized inside the rendering
`Template` instance by partial name. If the same instance renders
`{% render greeting %}` more than once, the loader is asked for `greeting` once
and the parsed partial nodes are reused.

This partial cache is also object-local:

- it does not share partial nodes across different `Template` instances
- it uses the partial name as the cache key
- it does not detect changes in loader-backed source

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

## Compiled Proc Direction

A smaller step than generating Ruby source would be compiling nodes into a Ruby
`Proc`.

Conceptually:

```text
nodes -> proc -> rendered output
```

That proc would still be built by this engine, but it could avoid repeatedly
dispatching on node classes during render. For example, a text node could become
a proc step that appends a fixed string, and a variable node could become a proc
step that performs a fixed lookup path.

However, even a proc-based compiler has to answer the same questions as a full
code generator:

- How are filters and helpers captured?
- How are partials loaded and cached?
- How are source positions preserved for errors?
- Does the compiled proc render into a string or stream into an output object?
- What invalidates a compiled partial?

The current implementation does not compile render procs yet. The next useful
learning step is to measure the current direct interpreter first, so any
compiled implementation has a concrete baseline to compare against.

## Benchmark Baseline

The repository includes a small benchmark script:

```sh
ruby benchmarks/render_benchmark.rb
```

Use `ITERATIONS` to change the loop count:

```sh
ITERATIONS=10000 ruby benchmarks/render_benchmark.rb
```

The benchmark compares:

- `Tpeg.render`, which creates a new `Template` and parses source each time
- reused `Template#render`, which reuses memoized parsed nodes
- loop rendering through the direct interpreter
- partial rendering with object-local partial node caching

The numbers are not a production performance claim. They are a baseline for
future experiments such as compiled render procs, generated Ruby, broader
template caches, or file-backed loader invalidation.

## Benchmark Observations

An early run with `ITERATIONS=10000` showed the expected shape:

- repeatedly calling `Tpeg.render` is much slower than reusing one
  `Tpeg::Template` instance
- object-local node caching removes a large amount of parse/setup cost
- loop rendering is slower than simple interpolation because lookup, condition
  checks, child contexts, and repeated output appends happen at render time
- partial rendering is close to loop rendering once partial nodes are cached,
  but it still has runtime cost for partial dispatch and context handling

The main learning point is that parsing is an obvious first cache boundary.
Compiled procs or generated Ruby should be compared against cached
`Template#render`, not against `Tpeg.render`, because otherwise the benchmark
mostly measures parsing instead of render execution.

Useful next measurements:

- simple cached render with many interpolations
- loop render with larger collections
- partial render with and without partial node caching
- helper/filter-heavy render paths
- allocation counts, not only elapsed time

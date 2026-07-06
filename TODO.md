# TODO

This file is a living learning roadmap for the Ruby template engine
implementation.

The roadmap is intentionally flexible. Update it whenever the learning goal,
implementation direction, or level of detail changes.

## Current Learning Goal

Build a small template engine in Ruby and use it to understand the mechanics
usually hidden by ERB, Liquid, Mustache, Haml, Rails views, and other template
systems.

Initial focus:

- Plain text rendering and interpolation.
- Source scanning and tokenization.
- A small parser and template representation.
- Rendering with a context and predictable variable lookup.
- HTML escaping and raw output decisions.
- Error reporting with useful source locations.
- Later exploration of control flow, helpers, partials, compilation, and
  caching.

## Roadmap

Roadmap sections are learning themes, not single work units. When moving the
project forward, advance by one small learning unit at a time unless a larger
scope is explicitly requested.

### 0. Project Setup

- [x] Define the project purpose.
- [x] Create initial project documentation.
- [x] Decide the first implementation milestone.
- [x] Decide the initial Ruby package layout after the first milestone is clear.
- [x] Decide how to organize learning notes.

First implementation milestone:

- Build a minimal renderer that returns plain text unchanged and replaces
  simple interpolation markers such as `{{ name }}` from a hash-like context.
- Keep conditionals, loops, helpers, partials, layouts, compilation, and caching
  out of scope until the basic source-to-output lifecycle is visible.

### 1. Minimal Interpolation Renderer

- [x] Create the initial Ruby project structure.
- [x] Add a minimal template rendering entry point.
- [x] Render plain text unchanged.
- [x] Replace `{{ name }}` with a value from the render context.
- [x] Decide behavior for missing variables.
- [x] Add small examples or tests for successful interpolation.
- [x] Add examples or tests for malformed interpolation markers.
- [x] Document the first source-to-output lifecycle.

Questions to answer:

- What is the smallest useful template syntax?
- Should missing variables render as empty strings or raise errors?
- What is the difference between the template source and rendered output?
- Where does string scanning become hard enough to justify a lexer?

### 2. Scanner And Lexer

- [x] Track byte offsets, line numbers, and column numbers.
- [x] Split source into text and interpolation tokens.
- [x] Preserve text exactly outside template delimiters.
- [x] Detect unterminated delimiters.
- [x] Decide whitespace behavior around delimiters.
- [x] Add tests for adjacent tokens, multiline templates, and malformed source.

Questions to answer:

- What metadata should every token carry?
- How should the tokenizer recover or fail on malformed syntax?
- What changes when delimiters appear inside plain text?
- How do line and column numbers improve diagnostics?

### 3. Parser And Template Representation

- [x] Define a small AST or render instruction model.
- [x] Parse text tokens into text nodes.
- [x] Parse interpolation tokens into variable lookup nodes.
- [x] Separate parsing errors from rendering errors.
- [x] Add tests for parser boundaries and invalid token sequences.

Questions to answer:

- When is an AST useful compared with rendering tokens directly?
- What should be validated at parse time?
- Which errors require source locations?
- How much expression syntax is useful before it becomes a separate language?

### 4. Rendering Context

- [x] Define context lookup behavior for symbols and strings.
- [x] Support nested lookup such as `user.name` if it remains useful.
- [x] Decide behavior for hashes, objects, and method calls.
- [x] Add a scoped context model for future loops and partials.
- [x] Avoid accidental mutation of user-provided context data.

Questions to answer:

- What should a template be allowed to read from the context?
- When should lookup raise instead of returning nil?
- How do nested scopes affect variable resolution?
- What are the safety risks of calling arbitrary Ruby methods?

### 5. Escaping And Output Safety

- [x] Add HTML escaping for interpolated values.
- [x] Decide the default escaping behavior.
- [x] Add explicit raw output syntax or API if useful.
- [x] Avoid double escaping where practical.
- [x] Compare selected behavior with ERB or Rails escaping.

Questions to answer:

- Why do template engines escape by default in HTML contexts?
- What makes a string safe or unsafe?
- How can raw output be made explicit?
- What output contexts are not covered by simple HTML escaping?

### 6. Control Flow

- [x] Tokenize control tags such as `{% if user %}`.
- [x] Reject unsupported control tags during parsing.
- [x] Parse conditional blocks.
- [x] Render conditional blocks.
- [x] Parse loop blocks.
- [x] Render loop blocks.
- [x] Validate nested block structure.
- [x] Decide truthiness and empty collection behavior.
- [x] Add tests for nested and malformed blocks.

Questions to answer:

- How does block syntax change the parser?
- What scope should loop variables live in?
- Which behavior should follow Ruby, and which should be template-specific?
- How should error messages point to the matching opening block?

### 7. Helpers, Filters, And Partials

- [x] Add one simple built-in filter.
- [x] Add per-render custom filter registration.
- [x] Decide how helpers are registered.
- [x] Add a minimal helper call syntax.
- [x] Add a template loader abstraction.
- [ ] Implement partial rendering.
- [ ] Explore layout rendering if it remains useful.

Questions to answer:

- What belongs in the template language versus helper Ruby code?
- How should helper errors be surfaced?
- How does a partial inherit or isolate context?
- What security boundary, if any, does a loader provide?

### 8. Compilation And Caching

- [ ] Compare direct AST interpretation with generated Ruby code.
- [ ] Add a parsed-template cache.
- [ ] Explore compiled render methods or procs.
- [ ] Add small benchmarks.
- [ ] Document tradeoffs and known limitations.

Questions to answer:

- When is compilation worth the complexity?
- What cache key identifies a template?
- How should cache invalidation work for file-backed templates?
- What does generated Ruby code make easier or harder to debug?

### 9. Robustness And Diagnostics

- [ ] Improve parse and render error classes.
- [ ] Include source snippets in syntax errors.
- [ ] Add tests for malformed templates and nested block mismatches.
- [ ] Add behavior comparisons with existing Ruby template engines.
- [ ] Document known limitations.

Questions to answer:

- What information makes a template error actionable?
- Which errors should be recoverable?
- How strict should the syntax be?
- What limitations are intentional for learning clarity?

### 10. Possible Next Learning Directions

- [ ] Explore ERB-like Ruby code execution.
- [ ] Explore Liquid-like safe templates for user-authored content.
- [ ] Explore Mustache-like logic-less rendering.
- [ ] Explore streaming rendered output.
- [ ] Explore source maps or better debug output for compiled templates.
- [ ] Compare performance and behavior with common Ruby template engines.

These are candidate directions, not a fixed plan.

## Learning Log

Use this section to record notable decisions, discoveries, and direction
changes.

- Initial direction: focus on template engine internals rather than building a
  production-ready replacement for existing Ruby template engines.
- First implementation milestone: start with plain text and simple
  interpolation before introducing lexer, parser, AST, escaping, control flow,
  partials, compilation, or caching.
- Added the initial Ruby layout with `lib/tpeg.rb`, `lib/tpeg/template.rb`, and
  `test/`.
- Added `Tpeg.render(source, context)` and `Tpeg::Template#render` as the first
  minimal rendering API.
- Implemented plain text rendering and simple `{{ name }}` interpolation using
  `StringScanner`.
- Decided that missing variables and malformed interpolation markers should
  raise explicit `Tpeg` errors in the first implementation.
- Documented the first source-to-output lifecycle in
  `docs/minimal-interpolation.md`.
- Added `Tpeg::Lexer` and `Tpeg::Token` as the first lexer boundary without
  changing renderer behavior yet.
- The lexer now emits `:text` and `:interpolation` tokens, preserves text
  outside delimiters, and reports delimiter-level syntax errors.
- Added source positions to tokens: zero-based byte offsets and one-based line
  and column numbers.
- Decided that interpolation token values trim surrounding delimiter whitespace,
  while text tokens preserve source text exactly.
- Updated the renderer to consume lexer tokens instead of scanning the source
  directly.
- Added `Tpeg::Parser`, `TextNode`, and `VariableNode` as the first
  token-to-node template representation.
- Parser nodes copy source positions from lexer tokens, but variable name
  validation still belongs to the renderer for now.
- Updated the renderer to consume parser nodes, making the current pipeline
  `source -> lexer tokens -> parser nodes -> rendered output`.
- Moved variable name validation into the parser, leaving missing context values
  as rendering errors.
- Added `Tpeg::RenderContext` to centralize string-key and symbol-key variable
  lookup during rendering.
- Decided that rendering context must be hash-like (`key?` and `[]`), and that
  arbitrary object method calls are not supported yet.
- Render context now shallow-copies and freezes top-level context values on
  initialization.
- Added dot-separated nested lookup through hash-like values, without calling
  arbitrary Ruby object methods.
- Added `RenderContext#with_locals` for child scopes that can shadow parent
  top-level values and fall back to parent lookup.
- Added default HTML escaping for interpolated values using Ruby's standard
  `CGI.escapeHTML`.
- Added `Tpeg.raw(value)` as an explicit API for values that should bypass HTML
  escaping.
- Decided that double escaping is avoided only for explicit `Tpeg.raw` values;
  ordinary strings are always escaped.
- Compared current HTML escaping with Ruby's `ERB::Util.html_escape` for basic
  HTML-sensitive characters and already-escaped plain strings.
- Added lexer support for `{% ... %}` control tag tokens as the first control
  flow boundary.
- Decided that unsupported control tags are parser errors instead of raw AST
  nodes.
- Added parser support for `{% if condition %}...{% end %}` as nested `IfNode`
  structures. Rendering conditional blocks is still pending.
- Added rendering for `IfNode`; conditions use Ruby-like truthiness where only
  `nil` and `false` are falsey.
- Added parser support for `{% for item in items %}...{% end %}` as nested
  `ForNode` structures. Rendering loop blocks is still pending.
- Added rendering for `ForNode` using `RenderContext#with_locals` so loop local
  variables can shadow parent values.
- Added explicit render coverage for nested `for` blocks that read both local
  and parent-scope values.
- Added a minimal `upcase` filter for interpolation expressions such as
  `{{ name | upcase }}`.
- Extracted built-in filter lookup into `Tpeg::Filters` so the renderer no
  longer owns the filter registry directly.
- Added `filters:` to `Tpeg.render` for per-render custom filter callables.
- Simplified `Tpeg.render` back to `Tpeg.render(source, context = {}, filters:
  {}, helpers: {})` so context data is passed explicitly as a hash.
- Decided that helpers should be registered per render call and called
  explicitly, without falling back to arbitrary Ruby method lookup.
- Added minimal helper interpolation syntax with variable-path arguments:
  `{{ helper_name(arg.path) }}`.
- Documented and tested that multiple filters in one interpolation are applied
  from left to right.
- Added `Tpeg::HashLoader` as the first template loader abstraction.

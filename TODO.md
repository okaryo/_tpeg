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
- [ ] Separate parsing errors from rendering errors.
- [x] Add tests for parser boundaries and invalid token sequences.

Questions to answer:

- When is an AST useful compared with rendering tokens directly?
- What should be validated at parse time?
- Which errors require source locations?
- How much expression syntax is useful before it becomes a separate language?

### 4. Rendering Context

- [ ] Define context lookup behavior for symbols and strings.
- [ ] Support nested lookup such as `user.name` if it remains useful.
- [ ] Decide behavior for hashes, objects, and method calls.
- [ ] Add a scoped context model for future loops and partials.
- [ ] Avoid accidental mutation of user-provided context data.

Questions to answer:

- What should a template be allowed to read from the context?
- When should lookup raise instead of returning nil?
- How do nested scopes affect variable resolution?
- What are the safety risks of calling arbitrary Ruby methods?

### 5. Escaping And Output Safety

- [ ] Add HTML escaping for interpolated values.
- [ ] Decide the default escaping behavior.
- [ ] Add explicit raw output syntax or API if useful.
- [ ] Avoid double escaping where practical.
- [ ] Compare selected behavior with ERB or Rails escaping.

Questions to answer:

- Why do template engines escape by default in HTML contexts?
- What makes a string safe or unsafe?
- How can raw output be made explicit?
- What output contexts are not covered by simple HTML escaping?

### 6. Control Flow

- [ ] Add conditional blocks.
- [ ] Add loop blocks.
- [ ] Validate nested block structure.
- [ ] Decide truthiness and empty collection behavior.
- [ ] Add tests for nested and malformed blocks.

Questions to answer:

- How does block syntax change the parser?
- What scope should loop variables live in?
- Which behavior should follow Ruby, and which should be template-specific?
- How should error messages point to the matching opening block?

### 7. Helpers, Filters, And Partials

- [ ] Add simple filters or helper functions.
- [ ] Decide how helpers are registered.
- [ ] Add a template loader abstraction.
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

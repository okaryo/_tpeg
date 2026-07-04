# _tpeg

`_tpeg` is a learning-oriented template engine implementation in Ruby.

The goal of this project is not to build a production-ready replacement for
ERB, Liquid, Mustache, Haml, or Rails views. The goal is to understand what sits
underneath template engines we usually use: scanning source text, tokenizing
template syntax, parsing expressions and blocks, building an intermediate
representation, rendering with a context, escaping output, reporting useful
errors, and deciding when compilation or caching is worth introducing.

## Purpose

This project is for studying template engine internals step by step.

The intended learning style is:

- Build small pieces incrementally.
- Confirm the learning objective before each major step.
- Prefer understanding the mechanism over quickly adding features.
- Compare behavior with Ruby's standard library and common template engines
  when useful.
- Keep the roadmap flexible as new questions and interests appear.

The project assumes that the learner is already comfortable with Ruby and basic
backend or Web development. Therefore, the focus is not on basic Ruby syntax or
ordinary application structure, but on deeper implementation details.

## Learning Topics

This project may cover topics such as:

- Source scanning: byte offsets, line and column tracking, delimiters, and
  preserving plain text.
- Lexing: token types, tokenizer state, whitespace handling, malformed syntax,
  and useful token metadata.
- Parsing: grammar choices, recursive descent parsing, block nesting,
  expression boundaries, and syntax errors.
- Intermediate representation: AST nodes, render instructions, compiled Ruby
  code, and tradeoffs between direct interpretation and compilation.
- Rendering context: variable lookup, missing values, nested data, scopes,
  locals, and immutable versus mutable render state.
- Escaping and safety: HTML escaping, raw output, safe strings, double escaping,
  and why template engines need output contexts.
- Control flow: conditionals, loops, block tags, includes, partials, layouts,
  and whitespace trimming.
- Extensibility: helpers, filters, custom functions, loaders, and template
  resolvers.
- Performance: caching parsed templates, compiled templates, allocation
  behavior, streaming output, and benchmark design.
- Robustness: diagnostics, source spans, error messages, tests for malformed
  templates, and behavior comparisons with existing engines.

## Non-goals

The following are not the main focus of this project:

- Building a full production-ready template engine.
- Replacing ERB, Liquid, Mustache, Haml, or Rails view rendering.
- Designing a complete secure sandbox for untrusted templates.
- Building a full Web framework or view layer.
- Prioritizing syntax breadth over implementation understanding.

Some production-oriented topics may still be explored when they help explain how
real template engines behave.

## Approach

The preferred starting point is a deliberately tiny template language:

1. Render plain text unchanged.
2. Replace simple interpolation markers such as `{{ name }}` from a render
   context.
3. Split source text into explicit text and interpolation tokens.
4. Parse those tokens into a small template representation.
5. Render the representation with predictable variable lookup behavior.
6. Add HTML escaping and a way to intentionally output raw values.
7. Explore conditionals, loops, helpers, partials, compilation, caching, and
   diagnostics.

At each stage, the implementation should remain small enough to inspect and
explain. When the design becomes unclear, the roadmap should be updated rather
than treated as fixed.

## Running the Current Engine

The current implementation is a minimal interpolation renderer.

Run a small example:

```sh
ruby -Ilib -e 'require "tpeg"; puts Tpeg.render("Hello, {{ name }}!", name: "Ruby")'
```

Run the tests:

```sh
ruby -Itest -Ilib -e 'Dir["test/**/*_test.rb"].sort.each { |path| load path }'
```

The renderer walks through the template source, copies plain text unchanged,
and replaces simple interpolation markers such as `{{ name }}` from a
hash-like context. Missing variables and malformed interpolation markers raise
explicit `Tpeg` errors instead of silently rendering empty output.

## Project Documents

- `README.md`: project purpose, scope, and high-level learning direction.
- `AGENTS.md`: working instructions for AI agents and future contributors.
- `TODO.md`: living learning roadmap and progress tracker.
- `docs/minimal-interpolation.md`: notes on the first plain text and
  interpolation rendering step.
- `docs/lexer.md`: notes on the first text and interpolation tokenization
  boundary.
- `docs/parser.md`: notes on the first token-to-node parser boundary.
- `docs/render-context.md`: notes on variable lookup during rendering.

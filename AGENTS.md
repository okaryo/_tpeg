# AGENTS.md

This repository is a learning project for implementing template engine internals
in Ruby. Agents should optimize for understanding, incremental progress, and
clear explanations rather than feature volume.

## Project Intent

The project explores how template engines work underneath common high-level
tools such as ERB, Liquid, Mustache, Haml, and Rails view rendering.

The learner is already comfortable with Ruby and basic backend or Web
development, so avoid spending too much time on basic Ruby syntax or ordinary
application structure. Prefer deeper discussion of source scanning, lexing,
parsing, AST design, rendering contexts, escaping, error reporting, caching, and
performance tradeoffs.

## Working Style

- Proceed step by step.
- Treat a request to proceed to the next step as permission to advance one small
  learning unit, not to complete an entire roadmap section, unless the user
  explicitly asks for a full section.
- Before a major implementation step, clarify the specific learning objective.
- After a meaningful implementation step, summarize what was learned and what
  remains unclear.
- Keep changes small and inspectable.
- Prefer Ruby standard library behavior first when the goal is to understand the
  mechanism.
- Use external libraries only when they help compare designs or when the learner
  explicitly wants to study that library.
- Keep `TODO.md` updated as a living roadmap, not a fixed plan.
- If the learning direction changes, update the roadmap instead of forcing the
  original plan.

## Implementation Guidance

- Prefer starting with a tiny custom syntax before copying the full behavior of
  ERB, Liquid, or another existing engine.
- Make scanner, lexer, parser, and renderer boundaries explicit once each
  boundary has a learning reason to exist.
- Keep parsing logic explicit enough to study. Recursive descent parsers, simple
  state machines, and small AST node classes are preferred over opaque
  shortcuts when the topic is template parsing.
- Be careful with output escaping, raw output, missing variables, nested scopes,
  and source-location metadata.
- When introducing abstractions such as template loaders, render contexts,
  helper registries, compiled templates, or caches, explain what problem the
  abstraction solves and which behavior it hides.
- When comparing with ERB, Liquid, Mustache, Haml, or Rails, focus on the
  underlying behavior rather than surface syntax convenience.
- Include tests or small reproducible examples where practical, especially for
  malformed templates, missing values, escaping, and nested blocks.

## Documentation Guidance

- `README.md` should describe the project purpose and scope.
- `TODO.md` should track the current learning roadmap, progress, and open
  questions.
- Add notes to `TODO.md` when a completed step changes the next learning
  direction.
- Add topic-specific notes under `docs/` once an implementation step creates a
  useful learning artifact.
- Do not treat the roadmap as immutable.

# ERB Comparison

ERB is Ruby's standard template engine. Comparing `_tpeg` with ERB is useful
because ERB takes a very different implementation path.

Run the executable comparison:

```sh
ruby -Ilib examples/erb_comparison.rb
```

This comparison starts with ERB because it is available in Ruby's standard
library. The project does not currently add Liquid, Mustache, Haml, or Rails
view comparisons; ERB is enough to contrast generated Ruby execution with
`_tpeg`'s AST interpretation without introducing more dependencies.

## Evaluation Model

ERB templates contain Ruby code:

```erb
Hello, <%= name %>!
```

ERB turns the template into Ruby source and evaluates that Ruby source. This
means template expressions can use Ruby variables, method calls, loops,
conditionals, and arbitrary Ruby code available in the evaluation binding.

`_tpeg` does not generate or execute Ruby code from templates. It parses the
source into small AST nodes and interprets those nodes:

```text
source -> lexer tokens -> parser nodes -> renderer
```

This keeps the learning boundary explicit. The template language only supports
features that `_tpeg` has intentionally implemented.

## Missing Values

With ERB, a missing local variable is a Ruby evaluation error:

```text
NameError: undefined local variable or method 'name' for main
```

With `_tpeg`, a missing value is a template rendering error with template
location:

```text
Tpeg::MissingVariable: missing variable: name at line 1, column 11
```

## Escaping

Plain ERB output is not escaped automatically:

```erb
<%= value %>
```

If `value` is `<b>Ruby</b>`, plain ERB outputs that HTML as-is.

`_tpeg` escapes interpolated values by default:

```text
{{ value }}
```

The same value renders as:

```html
&lt;b&gt;Ruby&lt;/b&gt;
```

Raw output in `_tpeg` must be explicit through `Tpeg.raw(value)`.

## Control Flow

ERB uses Ruby control flow:

```erb
<% if user %>
  <%= user[:name] %>
<% end %>
```

`_tpeg` uses template-specific block tags:

```text
{% if user %}
  {{ user.name }}
{% end %}
```

The ERB version follows Ruby semantics because it is Ruby code. The `_tpeg`
version follows the smaller rules implemented by `Tpeg::Parser`,
`Tpeg::RenderContext`, and `Tpeg::Template`.

## Safety Boundary

ERB is powerful because templates can run Ruby. That also means an ERB template
is not a safe language for untrusted template authors unless the surrounding
application adds its own restrictions.

`_tpeg` intentionally does not call arbitrary Ruby methods from variable lookup.
Helpers and filters must be registered explicitly. This makes the current engine
less expressive than ERB, but easier to reason about while studying parser,
context, and renderer boundaries.

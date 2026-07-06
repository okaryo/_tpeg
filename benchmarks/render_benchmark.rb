# frozen_string_literal: true

require "benchmark"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "tpeg"

ITERATIONS = Integer(ENV.fetch("ITERATIONS", "5000"))

context = {
  name: "Ruby",
  items: [
    { name: "Ruby", active: true },
    { name: "Go", active: false },
    { name: "Crystal", active: true }
  ]
}

simple_source = "Hello, {{ name | upcase }}!"
simple_template = Tpeg::Template.new(simple_source)

loop_source = "{% for item in items %}{% if item.active %}{{ item.name }};{% end %}{% end %}"
loop_template = Tpeg::Template.new(loop_source)

partial_loader = Tpeg::HashLoader.new(item: "{{ item.name }};")
partial_source = "{% for item in items %}{% if item.active %}{% render item %}{% end %}{% end %}"
partial_template = Tpeg::Template.new(partial_source, loader: partial_loader)

puts "iterations: #{ITERATIONS}"

Benchmark.bm(34) do |benchmark|
  benchmark.report("Tpeg.render simple") do
    ITERATIONS.times do
      Tpeg.render(simple_source, context)
    end
  end

  benchmark.report("Template#render simple cached") do
    ITERATIONS.times do
      simple_template.render(context)
    end
  end

  benchmark.report("Template#render loop cached") do
    ITERATIONS.times do
      loop_template.render(context)
    end
  end

  benchmark.report("Template#render partial cached") do
    ITERATIONS.times do
      partial_template.render(context)
    end
  end
end

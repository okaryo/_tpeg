# frozen_string_literal: true

require "erb"
require "tpeg"

def print_case(title)
  puts
  puts "== #{title} =="
end

def print_error(label)
  yield
rescue StandardError => error
  puts "#{label}: #{error.class}: #{error.message.lines.first.strip}"
end

print_case("Interpolation")
puts "ERB:  #{ERB.new("Hello, <%= name %>!").result_with_hash(name: "Ruby")}"
puts "Tpeg: #{Tpeg.render("Hello, {{ name }}!", { name: "Ruby" })}"

print_case("Missing value")
print_error("ERB") do
  puts ERB.new("Hello, <%= name %>!").result_with_hash({})
end
print_error("Tpeg") do
  puts Tpeg.render("Hello, {{ name }}!")
end

print_case("Escaping")
value = "<b>Ruby</b>"
puts "ERB:  #{ERB.new("<%= value %>").result_with_hash(value: value)}"
puts "Tpeg: #{Tpeg.render("{{ value }}", { value: value })}"

print_case("Control flow")
erb_source = "<% if user %><%= user[:name] %><% end %>"
tpeg_source = "{% if user %}{{ user.name }}{% end %}"
context = { user: { name: "Ruby" } }

puts "ERB:  #{ERB.new(erb_source).result_with_hash(user: context[:user])}"
puts "Tpeg: #{Tpeg.render(tpeg_source, context)}"

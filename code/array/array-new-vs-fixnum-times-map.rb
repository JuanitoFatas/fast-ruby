require "benchmark/ips"

ELEMENTS = 9

def fast
  Array.new(ELEMENTS) { |i| i }
end

def slow
  ELEMENTS.times.map { |i| i }
end

Benchmark.ips do |x|
  x.report("Array#new") { fast }
  x.report("Fixnum#times + map") { slow }
  x.compare!
end

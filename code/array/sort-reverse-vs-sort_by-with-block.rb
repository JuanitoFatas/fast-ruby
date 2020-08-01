require "benchmark/ips"

ARRAY = 100.times.map { rand(1_000_000_000) }

def fast
  ARRAY.sort.reverse
end

def slow
  ARRAY.sort_by(&:-@)
end

Benchmark.ips do |x|
  x.report('Array#sort.reverse')  { fast }
  x.report('Array#sort_by &:-@')  { slow }

  x.compare!
end

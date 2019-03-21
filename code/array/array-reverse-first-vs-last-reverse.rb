require 'benchmark/ips'

ARRAY = [*1..100]

def fast
  ARRAY.reverse.first(5)
end

def slow
  ARRAY.last(5).reverse
end

Benchmark.ips do |x|
  x.report('Array#last.reverse') { fast }
  x.report('Array#reverse.first') { slow }
  x.compare!
end

require 'benchmark/ips'

ARRAY = [*1..100]

def fast
  ARRAY.reverse.last(5)
end

def slow
  ARRAY.first(5).reverse
end

Benchmark.ips do |x|
  x.report('Array#first.reverse') { fast }
  x.report('Array#reverse.last') { slow }
  x.compare!
end

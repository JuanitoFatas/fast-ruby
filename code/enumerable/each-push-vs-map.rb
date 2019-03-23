require 'benchmark/ips'

ARRAY = (1..100).to_a

def fast
  ARRAY.map { |i| i }
end

def slow
  array = []
  ARRAY.each { |i| array.push i }
end

Benchmark.ips do |x|
  x.report('Array#map')         { fast }
  x.report('Array#each + push') { slow }
  x.compare!
end

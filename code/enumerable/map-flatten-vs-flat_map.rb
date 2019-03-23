require 'benchmark/ips'

ARRAY = (1..100).to_a

def fast
  ARRAY.flat_map { |e| [e, e] }
end

def slow_flatten_1
  ARRAY.map { |e| [e, e] }.flatten(1)
end

def slow_flatten
  ARRAY.map { |e| [e, e] }.flatten
end

Benchmark.ips do |x|
  x.report('Array#flat_map')       { fast           }
  x.report('Array#map.flatten(1)') { slow_flatten_1 }
  x.report('Array#map.flatten')    { slow_flatten   }
  x.compare!
end

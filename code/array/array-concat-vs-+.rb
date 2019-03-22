require 'benchmark/ips'

RANGE = (0..10_000).freeze

def fast
  array = []
  RANGE.each { |number| array.concat(Array.new(10, number)) }
end

def slow
  array = []
  RANGE.each { |number| array += Array.new(10, number) }
end

Benchmark.ips do |x|
  x.report('Array#concat') { fast }
  x.report('Array#+')      { slow }
  x.compare!
end

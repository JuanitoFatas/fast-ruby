require 'benchmark/ips'

ARRAY = [*1..1000]

def fast
  !ARRAY.empty?
end

def slow
  ARRAY.any?
end

Benchmark.ips do |x|
  x.report('!Array#empty?') { fast }
  x.report('Array#any?') { slow }
  x.compare!
end

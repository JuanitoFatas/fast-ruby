require 'benchmark/ips'

RANGE = (1..100)

def fast
  RANGE.map(&:to_s)
end

def slow
  RANGE.map { |i| i.to_s }
end

Benchmark.ips do |x|
  x.report('Symbol#to_proc') { fast }
  x.report('Block')          { slow }
  x.compare!
end

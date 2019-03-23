require 'benchmark/ips'

ARRAY = [*1..100]

def fast
  ARRAY.detect { |x| x.eql?(15) }
end

def slow
  ARRAY.select { |x| x.eql?(15) }.first
end

Benchmark.ips(20) do |x|
  x.report('Enumerable#detect') { fast }
  x.report('Enumerable#select.first') { slow }
  x.compare!
end
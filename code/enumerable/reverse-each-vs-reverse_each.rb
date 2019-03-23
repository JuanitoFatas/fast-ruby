require 'benchmark/ips'

ARRAY = (1..100).to_a

def fast
  ARRAY.reverse_each{|x| x}
end

def slow
  ARRAY.reverse.each{|x| x}
end

Benchmark.ips do |x|
  x.report('Array#reverse_each') { fast }
  x.report('Array#reverse.each') { slow }
  x.compare!
end

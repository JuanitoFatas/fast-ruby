require 'benchmark/ips'

DATA = [*0..1_000_000]

def slowest
  DATA.find { |number| number > 77_777_777 }
end

def slow
  DATA.sort.bsearch { |number| number > 77_777_777 }
end

def fastest
  DATA.bsearch { |number| number > 77_777_777 }
end

Benchmark.ips do |x|
  x.report('find')         { slowest }
  x.report('sort.bsearch') { slow }
  x.report('bsearch')      { fastest }
  x.compare!
end

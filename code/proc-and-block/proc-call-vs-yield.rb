require 'benchmark/ips'

def fast
  yield
end

def slow(&block)
  block.call
end

def slow2(&block)
  yield
end

def slow3(&block)

end

Benchmark.ips do |x|
  x.report('yield')      { fast { 1 + 1 } }
  x.report('block.call') { slow { 1 + 1 } }
  x.report('block + yield') { slow2 { 1 + 1 } }
  x.report('unused block') { slow3 { 1 + 1 } }
  x.compare!
end

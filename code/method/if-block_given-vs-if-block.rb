def fast(&block)
  if block
  end
end
def slow(&block)
  if block_given?
  end
end

require 'benchmark/ips'
Benchmark.ips do |bm|
  bm.report('if block')        {fast}
  bm.report('if block_given?') {slow}
  bm.compare!
end
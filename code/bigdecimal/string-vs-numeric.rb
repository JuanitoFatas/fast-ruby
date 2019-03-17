require 'benchmark/ips'
require 'bigdecimal'
require 'bigdecimal/util'

def fastest
  BigDecimal('1')
end

def fastest2
  BigDecimal('1.0')
end

def fast
  '1'.to_d
end

def fast2
  '1.0'.to_d
end

def slow
  BigDecimal(1)
end

def slow2
  1.to_d
end

def slowest
  BigDecimal(1.0, 2)
end

def slowest2
  1.0.to_d
end


Benchmark.ips do |x|
  x.report('integer string new')  { fastest }
  x.report('float string new')    { fastest2 }
  x.report('integer string to_d') { fast }
  x.report('float string to_d')   { fast2 }
  x.report('integer new')         { slow }
  x.report('integer to_d')        { slow2 }
  x.report('float new')           { slowest }
  x.report('float to_d')          { slowest2 }
  x.compare!
end

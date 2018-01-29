require "benchmark/ips"
require "active_support"
require "active_support/core_ext/object/try"

OBJ = Object.new

def fast
  OBJ &.itself &.itself
end

def slow
  OBJ && OBJ.itself && OBJ.itself.itself
end

def slowest
  OBJ.try!(:itself).try!(:itself)
end

Benchmark.ips do |x|
  x.report('safe navigation operator')  { fast }
  x.report('explicit presence check') { slow }
  x.report('#try!') { slowest }
  x.compare!
end

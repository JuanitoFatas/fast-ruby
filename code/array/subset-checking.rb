require 'benchmark/ips'
require 'set'

ARRAY1 = [*1..25]
ARRAY2 = [*1..100]

def slow_set
  ARRAY2.to_set.subset?(ARRAY1.to_set)
end

def slow_interception
  (ARRAY1 & ARRAY2) == ARRAY1
end

def slow_interception_size
  (ARRAY1 & ARRAY2).size == ARRAY1.size
end

def slow_minus_empty
  (ARRAY1 - ARRAY2).empty?
end

def fast
  ARRAY1.all?{|element| ARRAY2.include?(element) }
end

Benchmark.ips do |x|
  x.report("(a1 - a2).empty?") { slow_minus_empty }
  x.report("(a1 & a2) == a1") { slow_interception }
  x.report("Array#all?#include?") { fast }
  x.report("Array#&#size") { slow_interception_size }
  x.report("Set#subset?") { slow_set }
  x.compare!
end

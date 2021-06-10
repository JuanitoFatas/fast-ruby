require 'benchmark/ips'
require 'set'

HASH = Hash[*('a'..'z').map { |key| [key, true] }]
SET = Set[*('a'..'z').to_a]

def fast
  HASH.has_key?('n')
end

def slow
  SET.include?('n')
end

Benchmark.ips do |x|
  x.report('Hash#has_key?') { fast }
  x.report('Set#include?') { slow }
  x.compare!
end

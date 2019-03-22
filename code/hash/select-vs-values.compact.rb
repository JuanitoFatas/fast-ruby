require 'benchmark/ips'

ARRAY = Array.new(1000) { Random.rand }
VALUES = ARRAY.map { |v| v < 0.5 }
HASH = Hash[ARRAY.zip(VALUES)]

def fastest
  HASH.values.compact
end

def fast
  HASH.values.select { |v| v }
end

def slow
  HASH.select { |_k, v| v }.values
end

Benchmark.ips do |x|
  x.report('Hash#select#values') { slow }
  x.report("Hash#values.select") { fast }
  x.report("Hash#values#compact") { fastest }
  x.compare!
end
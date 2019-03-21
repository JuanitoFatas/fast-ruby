require 'benchmark/ips'

HASH = {
  a: 'foo',
  b: 'bar',
  c: 'baz',
  d: 'qux'
}.freeze

# Some of the keys may not exist in the hash; we want to keep the default values.
KEYS = %i[a c e f].freeze

def fast
  HASH.values_at(*KEYS)
end

def slow
  KEYS.map { |key| HASH[key] }
end

Benchmark.ips do |x|
  x.report('Hash#values_at       ') { fast }
  x.report('Array#map { Hash#[] }') { slow }
  x.compare!
end

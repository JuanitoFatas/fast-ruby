require 'benchmark/ips'

HASH = {
  a: 'foo',
  b: 'bar',
  c: 'baz',
  d: 'qux'
}.freeze

# Only keys that exist in the hash.
KEYS = %i[a c].freeze

def fast
  HASH.values_at(*KEYS)
end

def slow
  KEYS.map { |key| HASH[key] }
end

def slowest
  HASH.slice(*KEYS).values
end

Benchmark.ips do |x|
  x.report('Hash#values_at       ') { fast }
  x.report('Array#map { Hash#[] }') { slow }
  x.report('Hash#slice#values    ') { slowest }
  x.compare!
end

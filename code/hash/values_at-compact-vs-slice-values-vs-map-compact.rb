require 'benchmark/ips'

HASH = {
  a: 'foo',
  b: 'bar',
  c: 'baz',
  d: 'qux'
}.freeze

# Some of the keys may not exist in the hash; we don't care about the default values.
KEYS = %i[a c e f].freeze

# NOTE: This is the only correct method, if the default value of Hash may be not nil.
def fast
  HASH.slice(*KEYS).values
end

def slow
  HASH.values_at(*KEYS).compact
end

def slowest
  KEYS.map { |key| HASH[key] }.compact
end

Benchmark.ips do |x|
  x.report('Hash#slice#values     ') { fast }
  x.report('Hash#values_at#compact') { slow }
  x.report('Array#map#compact     ') { slowest }
  x.compare!
end

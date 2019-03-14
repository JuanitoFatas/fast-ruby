require 'benchmark/ips'

HASH = {
  one:   'foo',
  two:   'bar',
  three: 'baz',
  four:  'qux'
}
KEYS = %i[one three]

def fast
  HASH.values_at(*KEYS)
end

def slow
  HASH.slice(*KEYS).values
end

Benchmark.ips do |x|
  x.report('Hash#values_at   ') { fast }
  x.report('Hash#slice#values') { slow }
  x.compare!
end

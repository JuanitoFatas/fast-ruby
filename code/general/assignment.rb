require 'benchmark/ips'

def fast
  _a, _b, _c, _d, _e, _f, _g = :a, :b, :c, :d, :e, :f, :g
  nil
end

def fast2
  _a, _b, _c, _d, _e, _f, _g = %i[a b c d e f g]
  nil
end

def slow
  _a = :a
  _b = :b
  _c = :c
  _d = :d
  _e = :e
  _f = :f
  _g = :g
  nil
end

Benchmark.ips do |bm|
  bm.report('Direct Parallel Assignment') {fast}
  bm.report('Array Parallel Assignment')  {fast2}
  bm.report('Sequential Assignment')      {slow}
  bm.compare!
end
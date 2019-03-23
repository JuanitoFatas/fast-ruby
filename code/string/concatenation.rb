require 'benchmark/ips'

# 1 object
def fast
  'foo' 'bar'
end

def fast_interpolation
  "#{'foo'}#{'bar'}"
end

# 2 + 1 = 3 object
def slow_plus
  'foo' + 'bar'
end

# 2 + 1 = 3 object
def slow_concat
  'foo'.concat 'bar'
end

# 2 + 1 = 3 object
def slow_append
  'foo' << 'bar'
end

Benchmark.ips do |x|
  x.report('"#{\'foo\'}#{\'bar\'}"')   { fast_interpolation }
  x.report('"foo" "bar"')              { fast }
  x.report('String#+')                 { slow_plus }
  x.report('String#concat')            { slow_concat }
  x.report('String#append')            { slow_append }
  x.compare!
end

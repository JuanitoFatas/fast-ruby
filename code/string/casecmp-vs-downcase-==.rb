require 'benchmark/ips'

SLUG = 'ABCD'

def slowest
  SLUG.casecmp?('abcd')
end

def slow
  SLUG.downcase == 'abcd'
end

def fast
  SLUG.casecmp('abcd') == 0
end

Benchmark.ips do |x|
  x.report("String#casecmp?")      { slowest } if RUBY_VERSION >= "2.4.0".freeze
  x.report('String#downcase + ==') { slow }
  x.report('String#casecmp')       { fast }
  x.compare!
end

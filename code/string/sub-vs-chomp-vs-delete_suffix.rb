require 'benchmark/ips'

SLUG = 'YourSubclassType'

def fast
  SLUG.chomp('Type')
end

def faster
  SLUG.delete_suffix('Type')
end

def slow
  SLUG.sub(/Type\z/, '')
end

Benchmark.ips do |x|
  x.report("String#delete_suffix") { faster } if RUBY_VERSION >= '2.5.0'
  x.report("String#chomp") { fast }
  x.report('String#sub') { slow }
  x.compare!
end

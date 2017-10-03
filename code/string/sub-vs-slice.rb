require 'benchmark/ips'

SLUG = 'YourSubclassType'

def fastest
  SLUG[4..-1]
end

def faster
  SLUG.slice!('Your')
end

def fast
  SLUG.sub('Your', '')
end

def slow
  SLUG.slice!(/\AYour/)
end

def slower
  SLUG.slice!(0..3)
end

def slowest
  SLUG.sub(/\AYour/, '')
end

Benchmark.ips do |x|
  x.report("String#[integer, integer]")       { fastest }
  x.report("String#slice!('string')")         { faster }
  x.report("String#sub('string')")            { fast }
  x.report("String#slice!(/regexp/)")         { slow }
  x.report("String#slice!(integer, integer)") { slower }
  x.report('String#sub/regexp/')              { slowest }
  x.compare!
end

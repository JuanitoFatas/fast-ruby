require 'benchmark/ips'

SLUG = 'writing-fast-ruby'

def fast
  SLUG.tr('-', ' ')
end

def slow
  SLUG.gsub('-', ' ')
end

Benchmark.ips do |x|
  x.report('String#tr')   { fast }
  x.report('String#gsub') { slow }
  x.compare!
end

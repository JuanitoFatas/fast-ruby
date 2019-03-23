require 'benchmark/ips'

SLUG = "some_kind_of_root_url"

def fast
  SLUG.end_with?('_path', '_url')
end

def slower
  SLUG =~ /_(path|url)$/
end

def slow
  SLUG.match?(/_(path|url)$/)
end

Benchmark.ips do |x|
  x.report('String#end_with?') { fast }
  x.report('String#=~')        { slower }
  x.report('String#match?')    { slow } if RUBY_VERSION >= "2.4.0".freeze
  x.compare!
end

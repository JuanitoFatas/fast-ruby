require "benchmark/ips"

def fastest
  /boo/.match?('foo'.freeze)
end

def fast
  "foo".freeze.match?(/boo/)
end

def slow
  "foo".freeze =~ /boo/
end

def slower
  /boo/ === "foo".freeze  
end

def even_slower
  /boo/.match('foo'.freeze)
end

def slowest
  "foo".freeze.match(/boo/)
end

Benchmark.ips do |x|
  x.report("Regexp#match?") { fastest } if RUBY_VERSION >= "2.4.0".freeze
  x.report("String#match?") { fast } if RUBY_VERSION >= "2.4.0".freeze
  x.report("String#=~") { slow }
  x.report("Regexp#===") { slower }
  x.report("Regexp#match") { even_slower }
  x.report("String#match") { slowest }
  x.compare!
end

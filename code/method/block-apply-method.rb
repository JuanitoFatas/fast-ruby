require "benchmark/ips"

def do_something(n)
  4*n + 2
end

def fast
  [1, 2, 3].map { |n| do_something(n) }
end

def slow
  [1, 2, 3].map(&method(:do_something))
end

Benchmark.ips do |x|
  x.report("normal")  { fast }
  x.report("&method") { slow }
  x.compare!
end

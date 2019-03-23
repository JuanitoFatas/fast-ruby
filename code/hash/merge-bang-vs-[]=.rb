require 'benchmark/ips'

ENUM = (1..100)

def fast
  ENUM.each_with_object({}) do |e, h|
    h[e] = e
  end
end

def slow
  ENUM.each_with_object({}) do |e, h|
    h.merge!(e => e)
  end
end

Benchmark.ips do |x|
  x.report('Hash#[]=') { fast }
  x.report('Hash#merge!') { slow }
  x.compare!
end

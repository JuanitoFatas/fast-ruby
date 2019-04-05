require 'benchmark/ips'

ARRAY = [*1..100]

def fast
  # "It just happens to line up" case
  ARRAY.reverse.detect { |x| (x % 10).zero? }

  # "Middle of the road" case
  # ARRAY.reverse.detect { |x| ((x % 10) == 60) }

  # "Worst Case" scenario
  # ARRAY.reverse.detect { |x| x == 1 }
end

def slow
  # "It just happens to line up" case
  ARRAY.select { |x| (x % 10).zero? }.last

  # "Middle of the road" case
  # ARRAY.select { |x| ((x % 10) == 60)  }.last

  # "Worst Case" scenario
  # ARRAY.select { |x| x == 1  }.last
end

Benchmark.ips do |x|
  x.report('Enumerable#reverse.detect') { fast }
  x.report('Enumerable#select.last')    { slow }
  x.compare!
end


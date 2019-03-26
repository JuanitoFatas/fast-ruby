require "benchmark/ips"

ARRAY = [*1..100]

def fastest
  array = ARRAY
  index = 0
  size = array.size
  while index < size
    array[index] + index
    index += 1
  end
  array
end

def faster
  index = 0
  size = ARRAY.size
  while index < size
    ARRAY[index] + index
    index += 1
  end
  ARRAY
end

def fast
  index = 0
  while index < ARRAY.size
    ARRAY[index] + index
    index += 1
  end
  ARRAY
end

def slow
  ARRAY.each_with_index do |number, index|
    number + index
  end
end

Benchmark.ips do |x|
  x.report("While optimal", 'fastest;' * 1000)
  x.report("While cached size", 'faster;' * 1000)
  x.report("While simple", 'fast;' * 1000)
  x.report("each_with_index", 'slow;' * 1000)
  x.compare!
end

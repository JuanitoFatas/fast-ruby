RANGE = 0..127
ARRAY = RANGE.to_a

$memory = nil # Anti-bias
def each(enumerable)
  enumerable.each do |n| $memory = n end
end
def for_in(enumerable)
  for n in enumerable do $memory = n end
end

=begin rdoc
Most people wouldn’t even care about this ugly and obsolete strategy.

But ParadoxV5’s Ruby 2.7.0 @ Windows 10 benchmark results shows this is actually about
1.7× as fast as both +each+ and +for-in+ which rather was what this test was intended to compare.

ParadoxV5 thought that this would be an excellect benchmark reference.
But surprise!

Turns out random-access data structures like +Array+s are meant and optimized to be read like this,
unlike sequential data structures like +Range+s and (um) linked lists.
=end
def fast(array)
  i, length = 0, array.length
  while i < length do
    $memory = array[i]
    i += 1
  end
end

require 'benchmark/ips'
puts '== Range =='
Benchmark.ips do |bm|
  bm.report('each') {each(RANGE)}
  bm.report('for-in') {for_in(RANGE)}
  bm.compare!
end
puts '== Array =='
Benchmark.ips do |bm|
  bm.report('while') {fast(ARRAY)}
  bm.report('each') {each(ARRAY)}
  bm.report('for-in') {for_in(ARRAY)}
  bm.compare!
end
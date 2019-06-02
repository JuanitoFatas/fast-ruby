require 'benchmark/ips'

$array = [*1..100]

Benchmark.ips do |x|
  x.report("Array#length", "$array.length;" * 1_000)
  x.report("Array#size",   "$array.size;"   * 1_000)
  x.report("Array#count",  "$array.count;"  * 1_000)
  x.compare!
end

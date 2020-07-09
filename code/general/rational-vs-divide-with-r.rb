def avg
  Rational(2, 3)
end
def slowest1
  Rational('2/3')
end
def slow
  '2/3'.to_r
end

def slowest2
  2/3r
end
def fastest1
  2r/3
end
def fastest2
  2r/3r
end

require 'benchmark/ips'
Benchmark.ips do |bm|
  bm.report('Rational(2, 3)') {avg}
  bm.report("Rational('2/3')") {slowest1}
  bm.report("'2/3'.to_r") {slow}
  bm.report('2/3r') {slowest2}
  bm.report('2r/3') {fastest1}
  bm.report('2r/3r') {fastest2}
  bm.compare!
end
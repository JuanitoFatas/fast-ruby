=begin rdoc
== Problem
Enumeration chaining:
Which is the fastest way other than just reïnventing the existing wheels?

The wheels I’m referring to are Enumerable#sum and Enumerable#tally;
neither of which are in Ruby 2.2, by the way.

== Background
Eager mapping creates an intermediate Array,
whereas lazy mapping creates two intermediate Enumerator::Lazy’s.
=end
ENUM = 0..1_000
PROC = proc {|n| n / 10}

def fast # But memory demanding
  ENUM.map(&PROC).inject(:+)
end
def slow # But pwns less memory
  ENUM.lazy.map(&PROC).inject(:+)
end

##
# == Observation
require 'benchmark/ips'
Benchmark.ips do |bm|
  bm.report('Eager map') {fast}
  bm.report('Lazy map') {slow}
  bm.compare!
end
=begin rdoc
== Conclusion
Eager enumerate during high-perfomance mode;
lazy enumerate when the priority is saving memory while grinding bajillions of data.

== Error
For situations with long chains, much data and limited RAM,
there is still the possibility for lazy enumeration to be faster while
eager enumeration spends heavy effort on GC-ing.
Covering these tests would create a lot of variables, however.
=end
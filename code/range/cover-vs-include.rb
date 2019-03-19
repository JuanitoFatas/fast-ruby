require "benchmark/ips"
require "date"

BEGIN_OF_JULY = Date.new(2015, 7, 1)
END_OF_JULY = Date.new(2015, 7, 31)
DAY_IN_JULY = Date.new(2015, 7, 15)

Benchmark.ips do |x|
  x.report('range#cover?') { (BEGIN_OF_JULY..END_OF_JULY).cover? DAY_IN_JULY }
  x.report('range#include?') { (BEGIN_OF_JULY..END_OF_JULY).include? DAY_IN_JULY }
  x.report('range#member?') { (BEGIN_OF_JULY..END_OF_JULY).member? DAY_IN_JULY }
  x.report('plain compare') { BEGIN_OF_JULY < DAY_IN_JULY && DAY_IN_JULY < END_OF_JULY }
  x.report('between?') { DAY_IN_JULY.between?(BEGIN_OF_JULY,END_OF_JULY) }
  
  x.compare!
end

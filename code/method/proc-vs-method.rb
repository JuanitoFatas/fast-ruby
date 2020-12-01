require 'benchmark/ips'

class MethodCall
  def call_method
  end
end

def fast
  MethodCall.new.method(:call_method).call
end

def slow
  -> { MethodCall.new.call_method }.call
end

Benchmark.ips do |x|
  x.report('#method') { fast }
  x.report('proc')    { slow }
  x.compare!
end

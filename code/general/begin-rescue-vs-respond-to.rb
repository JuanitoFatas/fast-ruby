require 'benchmark/ips'

def fast
  if respond_to?(:writing)
    writing
  else
    'fast ruby'
  end
end

def slow
  begin
    writing
  rescue
    'fast ruby'
  end
end

Benchmark.ips do |x|
  x.report('respond_to?')    { fast }
  x.report('begin...rescue') { slow }
  x.compare!
end

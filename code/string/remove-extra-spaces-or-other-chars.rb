require 'benchmark/ips'

PASSAGE = <<~LIPSUM
  Lorem ipsum dolor sit amet,  consectetur adipiscing  elit, sed do eiusmod    tempor incididunt ut  labore et dolore magna aliqua. 
  Ut enim ad  minim veniam, quis    nostrud exercitation ullamco laboris    nisi ut aliquip ex ea commodo consequat. 
  Duis aute    irure dolor in reprehenderit    in voluptate velit    esse cillum dolore eu    fugiat nulla pariatur. 
  Excepteur sint  occaecat cupidatat non    proident, sunt in culpa qui officia    deserunt mollit  anim id est laborum.
LIPSUM

raise unless PASSAGE.gsub(/ +/, " ") == PASSAGE.squeeze(" ")

def fast
  PASSAGE.squeeze(" ")
end

def slow
  PASSAGE.gsub(/ +/, " ")
end

Benchmark.ips do |x|
  x.report('String#squeeze')    { fast }
  x.report('String#gsub/regex+/') { slow }
  x.compare!
end

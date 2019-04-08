require "benchmark/ips"

# While using symbols on small hashes IS faster, the difference is very insignificant  even on 10_000_000 iterations
# From fastest to slowest.
#
def symbol_key
  {symbol: 42}
end

def symbol_key_arrow
  {:symbol => 42}
end

def symbol_key_in_string_form
  {'sym_str': 42}
end

def string_key_arrow_double_quotes
  {"string" => 42}
end

def string_key_arrow_single_quotes
  {'string' => 42}
end



Benchmark.ips do |x|

  puts "Generating simple Hashes with just 1 key/value using different types of keys"
  puts "Generating using implicit form"

  x.report("{symbol: 42}")       {symbol_key}
  x.report("{:symbol => 42}")    {symbol_key_arrow}
  x.report("{'sym_str': 42}")    {symbol_key_in_string_form}
  x.report("{\"string\" => 42}") {string_key_arrow_double_quotes}
  x.report("{'string' => 42}")   {string_key_arrow_double_quotes}

  x.compare!
end

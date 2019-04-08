require "benchmark/ips"


STRING_KEYS = (1..1000).map{|x| "key_#{x}"}.shuffle
FROZEN_KEYS = STRING_KEYS.map{|x| "fr_#{x}".freeze}
SYMBOL_KEYS = STRING_KEYS.map(&:to_sym)

# If we use static values for Hash, speed improves even more.
def symbol_hash
  SYMBOL_KEYS.collect { |k| [ k, rand(1..100)]}.to_h
end

def string_hash
  STRING_KEYS.collect { |k| [ k, rand(1..100)]}.to_h
end

# See this article for the discussion of using frozen strings instead of symbols
# http://blog.arkency.com/could-we-drop-symbols-from-ruby/
def frozen_hash
  FROZEN_KEYS.collect { |k| [ k, rand(1..100)]}.to_h
end


SYMBOL_HASH = symbol_hash
STRING_HASH = string_hash
FROZEN_HASH = frozen_hash


def reading_symbol_hash
  SYMBOL_HASH[SYMBOL_KEYS.sample]
end

def reading_string_hash
  STRING_HASH[STRING_KEYS.sample]
end

def reading_frozen_hash
  FROZEN_HASH[FROZEN_KEYS.sample]
end

Benchmark.ips do |x|

  puts "Creating large Hash"
  x.report("Symbol Keys") { symbol_hash }
  x.report("String Keys") { string_hash }
  x.report("Frozen Keys") { frozen_hash }

  x.compare!
end

Benchmark.ips do |x|
  puts "Reading large Hash"
  x.report("Symbol Keys") { reading_symbol_hash }
  x.report("String Keys") { reading_string_hash }
  x.report("Frozen Keys") { reading_frozen_hash }
  x.compare!
end

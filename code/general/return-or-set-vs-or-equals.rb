require 'benchmark/ips'

TIMES = Integer(ARGV.fetch(0, 100))
VALUE = 'some value'.freeze

class Memoizer
  def initialize
    @value = nil
  end

  # For trying again if nil and not sure if variable is defined
  def or_equals
    @value ||= VALUE
  end

  # For trying again if nil and sure the variable is defined
  def or_equals2
    @value || @value = VALUE
  end

  # For trying again if nil and not sure if variable is defined
  def return1
    return @value if defined?(@value) && @value
    @value = VALUE
  end

  # For trying again if nil and sure the variable is defined
  def return2
    return @value if @value
    @value = VALUE
  end

  # For not trying again if nil and not sure if variable is defined
  def return3
    return @value if defined?(@value)
    @value = VALUE
  end
end

def slow
  object = Memoizer.new
  TIMES.times do
    object.or_equals
  end
end

def slow2
  object = Memoizer.new
  TIMES.times do
    object.return1
  end
end

def slow3
  object = Memoizer.new
  TIMES.times do
    object.return3
  end
end

def fast
  object = Memoizer.new
  TIMES.times do
    object.return2
  end
end

def fastest
  object = Memoizer.new
  TIMES.times do
    object.or_equals2
  end
end

Benchmark.ips do |x|
  x.report('||=') { slow }
  x.report('return @value if defined?(@value) && @value') { slow2 }
  x.report('return @value if defined?(@value)') { slow3 }
  x.report('return @value if @value') { fast }
  x.report('@value || @value = VALUE') { fastest }
  x.compare!
end

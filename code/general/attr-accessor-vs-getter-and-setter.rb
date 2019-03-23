require 'benchmark/ips'

class User
  attr_accessor :first_name

  def last_name
    @last_name
  end

  def last_name=(value)
    @last_name = value
  end

end

def fast
  user = User.new
  user.first_name = 'John'
  user.first_name
end

def slow
  user = User.new
  user.last_name = 'John'
  user.last_name
end

Benchmark.ips do |x|
  x.report('attr_accessor')     { fast }
  x.report('getter_and_setter') { slow }
  x.compare!
end

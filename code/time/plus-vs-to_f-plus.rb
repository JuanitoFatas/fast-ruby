require 'benchmark/ips'

TimeFloatLowPrecision = 1525262447.0
OffsetFloatLowPrecision = 1.1
TimeFloatHighPrecision = 1525262447.1234567
OffsetFloatHighPrecision = 1.1234567

TimeLowPrecision = Time.at(TimeFloatLowPrecision)
TimeHighPrecision = Time.at(TimeFloatHighPrecision)

def fast_low_precision
  Time.at(TimeLowPrecision.to_f + OffsetFloatLowPrecision)
end

def slow_low_precision
  TimeLowPrecision + OffsetFloatLowPrecision
end

def fast_high_precision
  Time.at(TimeHighPrecision.to_f + OffsetFloatHighPrecision)
end

def slow_high_precision
  TimeHighPrecision + OffsetFloatHighPrecision
end

Benchmark.ips do |x|
  x.report('Time#to_f+ (low)', 'fast_low_precision;' * 1000)
  x.report('Time#+ (low)', 'slow_low_precision;' * 1000)
  x.report('Time#to_f+ (high)', 'fast_high_precision;' * 1000)
  x.report('Time#+ (high)', 'slow_high_precision;' * 1000)
  x.compare!
end
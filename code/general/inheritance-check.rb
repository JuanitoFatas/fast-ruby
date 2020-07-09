require 'benchmark/ips'

# You may ask: 'Is there a project that still using `ancestors.include?`?'
# By quick searching, I found the following popular repositories are still using it:
# - rake 
#   - https://github.com/ruby/rake/blob/7d0c08fe4e97083a92d2c8fc740cb421fd062117/lib/rake/task_manager.rb#L28
# - warden 
#   - https://github.com/hassox/warden/blob/090ed153dbd2f5bf4a1ca672b3018877e21223a4/lib/warden/strategies.rb#L16
# - metasploit-framework
#   - https://github.com/rapid7/metasploit-framework/blob/cac890a797d0d770260074dfe703eb5cfb63bd46/lib/msf/core/payload_set.rb#L239
#   - https://github.com/rapid7/metasploit-framework/blob/cb82015c8782280d964e222615b54c881bd36bbe/lib/msf/core/exploit.rb#L1440
# - hanami
#   - https://github.com/hanami/hanami/blob/506a35e5262939eb4dce9195ade3268e19928d00/lib/hanami/components/routes_inspector.rb#L54
#   - https://github.com/hanami/hanami/blob/aec069b602c772e279aa0a7f48d1a04d01756ee3/lib/hanami/configuration.rb#L114

def fast
  (Class <= Class)
  (Class <= Module)
  (Class <= Object)
  (Class <= Kernel)
  (Class <= BasicObject)
end

def slow
  Class.ancestors.include?(Class)
  Class.ancestors.include?(Module)
  Class.ancestors.include?(Object)
  Class.ancestors.include?(Kernel)
  Class.ancestors.include?(BasicObject)
end

Benchmark.ips do |x|
  x.report('less than or equal') { fast }
  x.report('ancestors.include?') { slow }
  x.compare!
end

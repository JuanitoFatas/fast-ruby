require 'benchmark/ips'

WORDS = 'writing fast ruby'
SPACE = ' '

def use_gsub
  WORDS.gsub(' ', '')
end

def use_tr
  WORDS.tr(' ', '')
end

def use_delete
  WORDS.delete(' ')
end

def use_delete_const
  WORDS.delete(SPACE)
end

Benchmark.ips do |x|
  x.report('String#gsub') { use_gsub }
  x.report('String#tr') { use_tr }
  x.report('String#delete') { use_delete }
  x.report('String#delete (const)') { use_delete_const }
  x.compare!
end

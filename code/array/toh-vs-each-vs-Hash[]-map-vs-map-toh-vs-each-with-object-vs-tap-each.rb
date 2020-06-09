# frozen_string_literal: true

require "benchmark/ips"

class People
  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  def login
    "#{first_name.downcase}-#{last_name.downcase}"
  end

  private

  attr_reader :first_name, :last_name
end

PEOPLE = [People.new('John', 'Doe'), People.new('Lola', 'Lanos')].freeze

def fast
  hash = {}
  PEOPLE.dup.each { |person| hash[person.login] = person }
  hash
end

def slow_to_h
  PEOPLE.dup.to_h { |person| [person.login, person] }
end

def slow_hash_new_map
  Hash[PEOPLE.dup.map { |person, hash| [person.login, person] }]
end

def slow_map_to_h
  PEOPLE.dup.map { |person, hash| [person.login, person] }.to_h
end

def slow_each_with_object
  PEOPLE.dup.each_with_object({}) { |person, hash| hash[person.login] = person }
end

def slow_tap
  {}.tap { |new_hash| PEOPLE.dup.each { |person, foo| new_hash[person.login] = person } }
end

Benchmark.ips do |x|
  x.report("Array#each")                  { fast }
  x.report("Array#to_h")                  { slow_to_h }
  x.report("Hash::[] plus Array#map")     { slow_hash_new_map }
  x.report("Array#map plus Array#to_h")   { slow_map_to_h }
  x.report("Enumerable#each_with_object") { slow_each_with_object }
  x.report("Object#tap plus Array#each")  { slow_tap }
  x.compare!
end

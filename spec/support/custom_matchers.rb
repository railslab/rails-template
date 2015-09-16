require 'rspec/expectations'

RSpec::Matchers.define :cast_to_string_using do |expected|
  match do |actual|
    # set some random value
    actual.send("#{expected}=".to_sym, rand.to_s)
    actual.send(expected.to_sym) == actual.to_s
  end

  failure_message do |actual|
    "expected #{actual.class}.to_s to return #{actual.class}.#{expected}, but returned #{actual.to_s.inspect}"
  end
end

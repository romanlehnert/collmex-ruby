require "rspec"
require "awesome_print"
require "vcr"
require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.color = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    Collmex.setup_login_data({username: "8866413", password: "2291502", customer_id: "104156"})
  end

  config.after(:each) do
    Collmex.reset_login_data
  end
end

def timed(name)
  start = Time.now
  puts "\n[STARTED: #{name}]"
  yield if block_given?
  finish = Time.now
  puts "[FINISHED: #{name} in #{(finish - start) * 1000} milliseconds]"
end

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
end

require "collmex"

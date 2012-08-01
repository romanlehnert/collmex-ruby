require 'spec_helper'
require 'yaml'
require 'collmex'
require "vcr"
require "pry"



describe Collmex do
  it {should respond_to :username}
  it {should respond_to :password}
  it {should respond_to :customer_id}
end


describe "CollmexIntegration" do

  before(:each) do 
    Collmex.setup_login_data
  end

  after(:each) do
    Collmex.reset_login_data
  end

  it "should work with the long form" do

    request = Collmex::Request.new

    c1 = request.add_command Collmex::Api::CustomerGet.new(customer_id: 9999)
    c2 = request.add_command Collmex::Api::AccdocGet.new()
    c3 = request.add_command Collmex::Api::AccdocGet.new(accdoc_id: 1)

    VCR.use_cassette('standard_request') do
      request.execute
    end

      
  end

  it "should work with the block form" do

    request = Collmex::Request.run do
      #enqueue :accdoc_get,   id: 1
      enqueue :customer_get, id: 9999
    end

    ap request.response.first

    request.response.last.success?.should eql true
  end
end



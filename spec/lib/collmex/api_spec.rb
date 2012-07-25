require "spec_helper"


describe Collmex::Api do

  describe ".is_a_collmex_command_obj?" do
    it "should fail for an array" do
      a = Array.new
      described_class.is_a_collmex_command_obj?(a).should be_false
    end

    it "should succeed for a Collmex::Api Object" do
      b = Collmex::Api::AccdocGet.new() 
      described_class.is_a_collmex_command_obj?(b).should be_true
    end
  end

  subject { described_class.new }

  specify { subject.should be_a Collmex::Api }

  describe Collmex::Api::Login do

    subject { Collmex::Api::Login.new({:username => 12, :password => 34}) }

    spec = ["LOGIN", 12, 34]
    specify { subject.to_a.should eql spec }

  end

  describe Collmex::Api::CustomerGet do
    subject { Collmex::Api::CustomerGet.new( {:customer_id => 9999} ) }
    spec = ["CUSTOMER_GET", 9999, 1]
    specify { subject.to_a.should eql spec }
    puts subject.kind_of? Collmex::Api
  end

  describe Collmex::Api::AccdocGet do
    subject { Collmex::Api::AccdocGet.new( {:accdoc_id => nil} ) }
    spec = ["ACCDOC_GET", 1, nil, nil]
    specify { subject.to_a.should eql spec }
  end
end






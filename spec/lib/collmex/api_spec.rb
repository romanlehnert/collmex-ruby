require "spec_helper"
require "csv"

describe Collmex::Api do

  subject { described_class.new }

  specify { subject.should be_a Collmex::Api }

  describe Collmex::Api::Login do

    subject { Collmex::Api::Login.new({:username => 12, :password => 34}) }

    spec = ["LOGIN", 12, 34, "asd"]
    specify { subject.to_a.should eql spec }

  end

end






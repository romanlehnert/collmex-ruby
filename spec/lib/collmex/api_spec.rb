require "spec_helper"

sample_spec = [  
          { name: :a,    type: :string },
          { name: :b,    type: :currency },
          { name: :c,    type: :float },
          { name: :d,    type: :integer },
]

empty_hash = { a: "", b: 0, c: 0.0, d: 0 }

empty_array = ["", 0, 0.0, 0]
filled_array = ["asdasd", 20, 0.0, 0]
filled_csv   = "asdasd;0,20;0,00;0\n"


describe Collmex::Api do

  describe ".is_a_collmex_api_line_obj?" do
    it "should fail for an array" do
      a = Array.new
      described_class.is_a_collmex_api_line_obj?(a).should be_false
    end

    it "should succeed for a Collmex::Api Object" do
      b = Collmex::Api::AccdocGet.new() 
      described_class.is_a_collmex_api_line_obj?(b).should be_true
    end
  end

  describe ".stringify_field" do
    tests = [
              { type: :string,      input: "asd",             outcome: "asd" },
              { type: :string,      input: "",                outcome: "" },
              { type: :string,      input: nil,               outcome: "" },

              { type: :integer,     input: nil,               outcome: "0" },
              { type: :integer,     input: 2,                 outcome: "2" },
              { type: :integer,     input: 2.2,               outcome: "2" },
              { type: :integer,     input: -2.2,              outcome: "-2" },
              { type: :integer,     input: "-2.2",            outcome: "-2" },

              { type: :float,       input: 2.2,               outcome: "2,20" },
              { type: :float,       input: 2,                 outcome: "2,00" },
              { type: :float,       input: "2",               outcome: "2,00" },
              { type: :float,       input: "-2.00",           outcome: "-2,00" },
              { type: :float,       input: -2.00,             outcome: "-2,00" },

              { type: :currency,    input: 2,                 outcome: "0,02" },
              { type: :currency,    input: "2",               outcome: "0,02" },
              { type: :currency,    input: "-2.23",           outcome: "-2,23" },   # <= WARNING
              { type: :currency,    input: "-2,23",           outcome: "-2,23" },   # <= WARNING
              { type: :currency,    input: -2.00,             outcome: "-0,02" },
              { type: :currency,    input: -2.90,             outcome: "-0,03" },
              { type: :currency,    input: -102.90,           outcome: "-1,03" },    # <= WARNING


    ]
    tests.each do |test|
      it "should represent #{test[:type]} \"#{test[:input].inspect}\" as \"#{test[:outcome]}\"" do
        described_class.stringify(test[:input],test[:type]).should === test[:outcome]
      end
    end
  end

  describe ".parse_field" do
    klass = Collmex::Api
  
    tests = [
              { type: :string,      input: "asd",             outcome: "asd" },
              { type: :string,      input: "2",               outcome: "2" },
              { type: :string,      input: "2",               outcome: "2" },
              { type: :string,      input: 2,                 outcome: "2" },
              { type: :string,      input: "-2.3",            outcome: "-2.3" },
              { type: :string,      input:  nil,              outcome: "" },

              { type: :integer,     input: "2,3",             outcome: 2 },          # <= WARNING
              { type: :integer,     input: "2",               outcome: 2 },
              { type: :integer,     input: "2.2",             outcome: 2 },
              { type: :integer,     input: 2,                 outcome: 2 },
              { type: :integer,     input: 2.2,               outcome: 2 },
              { type: :integer,     input: nil,               outcome: 0 },          # <= WARNING

              { type: :float,       input: "2",               outcome: 2.0 },
              { type: :float,       input: 2,                 outcome: 2.0 },
              { type: :float,       input: 2.2,               outcome: 2.2 },
              { type: :float,       input: "2,0",             outcome: 2.0 },
              { type: :float,       input: "2.0",             outcome: 2.0 },
              { type: :float,       input: "2,3",             outcome: 2.3 },
              { type: :float,       input: "-2,3",            outcome: -2.3 },
              { type: :float,       input: "2.2",             outcome: 2.2 },
              { type: :float,       input: nil,               outcome: 0.0 },

              { type: :currency,    input: "2",               outcome: 2 },
              { type: :currency,    input: 2,                 outcome: 2 },
              { type: :currency,    input: 2.20,              outcome: 220 },
              { type: :currency,    input: "0",               outcome: 0 },
              { type: :currency,    input: "0000",            outcome: 0 },
              { type: :currency,    input: "2,0",             outcome: 200 },
              { type: :currency,    input: "2,1",             outcome: 210 },
              { type: :currency,    input: "-2,1",            outcome: -210 },
              { type: :currency,    input: "-2,1",            outcome: -210 },
              { type: :currency,    input: "20,00",           outcome: 2000 },
              { type: :currency,    input: "20,12",           outcome: 2012 },
              { type: :currency,    input: "-20,12",          outcome: -2012 },
              { type: :currency,    input: nil,               outcome: 0 },
              { type: :currency,    input: "-20.12",          outcome: -2012 },
              { type: :currency,    input: "-20.",            outcome: -2000 },
              { type: :currency,    input: "20.",             outcome: 2000 },
              { type: :currency,    input: ".20",             outcome: 20 },
              { type: :currency,    input: "-,20",            outcome: -20 },
              { type: :currency,    input: ",20",             outcome: 20 },

              { type: :currency,    input: "20,000",          outcome: 20000 },
              { type: :currency,    input: "123,456",         outcome: 123456 },
              { type: :currency,    input: "123,456,789",     outcome: 123456789 },
              { type: :currency,    input: "123.456.789",     outcome: 123456789 },
              { type: :currency,    input: "23.456.789",      outcome: 23456789 },
              { type: :currency,    input: "-23.456.000",     outcome: -23456000 },
              { type: :currency,    input: "-23,456,000",     outcome: -23456000 },

              { type: :currency,    input: "-23,456.00",      outcome: -2345600 },
              { type: :currency,    input: "23,456.13",       outcome: 2345613 },

              { type: :currency,    input: "21,000",          outcome: 21000 },
              { type: :currency,    input: "12.345,20",       outcome: 1234520 },

            ]
    tests.each_with_index do |t,i|
      it "should parse #{t[:type]} value for \"#{t[:input]}\"" do
        klass.parse_field( t[:input], t[:type]).should === t[:outcome]
      end
    end
  end
end

describe Collmex::Api::Line do 

  describe ".hashify" do
    
    string    = "teststring"
    integer   = 421 
    float     = 123.23
    currency  = 100

    output = { a: string, b: currency, c: float, d: integer }

    before(:each) do 
      Collmex::Api::Line.stub(:specification).and_return(sample_spec)
      Collmex::Api.stub(:parse_field).with(anything(),:string).and_return string
      Collmex::Api.stub(:parse_field).with(anything(),:float).and_return float
      Collmex::Api.stub(:parse_field).with(anything(),:integer).and_return integer
      Collmex::Api.stub(:parse_field).with(anything(),:currency).and_return currency
    end

    tests = [
                [1,2,3,4],          
                [1,nil,3],     
                [1],          
                {a: 1, b:nil}, 
                {},           
                {c: 3},        
                "1;2;3",       
                "1;-2;3",      
                "1;-2,5;3",  
                ";;3",         
    ]

    tests.each do |testdata|
      it "should return the expected output for input \"#{testdata}\"" do
        Collmex::Api::Line.hashify(testdata).should eql output
      end
    end
  end

  

  describe ".empty_hash" do
    it "should hold a specification" do
        Collmex::Api::Line.specification.should eql({})
        Collmex::Api::Line.default_hash.should eql({})

        Collmex::Api::Line.stub(:specification).and_return(sample_spec)
        Collmex::Api::Line.default_hash.should eql(empty_hash)
      end
  end


  subject { Collmex::Api::Line.new }

  it { should respond_to :to_csv }
  it { should respond_to :to_a }
  it { should respond_to :to_s }
  it { should respond_to :to_h }

  describe "#initialize" do

    it "should set the instance_variable hash" do
      line = Collmex::Api::Line.new()
      line.instance_variable_get(:@hash).should be_a Hash
    end

    context "no params given" do
      it "should build the specified but empty hash" do
        Collmex::Api::Line.stub(:default_hash).and_return(empty_hash)
        line = Collmex::Api::Line.new
        line.to_h.should eql(empty_hash)
      end
    end

    context "something given" do
      it "should build the specified and filled hash" do
        input = {:a => "bla" }
        output = empty_hash.merge(input)

        Collmex::Api::Line.stub(:default_hash).and_return(empty_hash)
        Collmex::Api::Line.stub(:hashify).and_return(output)
        line = Collmex::Api::Line.new(input)
        line.to_h.should eql (output)
      end
    end
  end

  describe "#to_a" do
    it "should return the empty_hash translated to an array" do
      Collmex::Api::Line.stub(:specification).and_return(sample_spec)
      subject.to_a.should eql empty_array
    end
  end

  describe "#to_h" do

    it "should return the hash" do 
      h = { first: 1, second: 2 }
      subject.instance_variable_set(:@hash, h)
      subject.to_h.should eql h
    end

  end

  describe "#to_csv" do
    it "should represent the request as csv" do
      described_class.stub(:specification).and_return(sample_spec)
      subject.instance_variable_set(:@hash, described_class.hashify(filled_array))
      subject.to_csv.should eql filled_csv
      #subject.to_csv.should eql CSV.generate_line(filled_array, Collmex.csv_opts)
    end
  end
end

shared_examples_for "Collmex Api Command" do
  it { should respond_to :to_csv }
  it { should respond_to :to_s }
end

describe Collmex::Api::Login do
  subject { Collmex::Api::Login.new({:username => 12, :password => 34}) }
  it_behaves_like "Collmex Api Command" 
  spec = ["LOGIN", 12, 34]
  specify { subject.to_a.should eql spec }
end

describe Collmex::Api::CustomerGet do
  subject { Collmex::Api::CustomerGet.new( {:customer_id => 9999} ) }
  it_behaves_like "Collmex Api Command" 
  spec = ["CUSTOMER_GET", 9999, 1]
  specify { subject.to_a.should eql spec }
end

describe Collmex::Api::AccdocGet do
  subject { Collmex::Api::AccdocGet.new( {:accdoc_id => nil} ) }
  it_behaves_like "Collmex Api Command" 
  spec = ["ACCDOC_GET", 1, nil, nil]
  specify { subject.to_a.should eql spec }
end






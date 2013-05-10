require "spec_helper"

sample_spec = [
          { name: :identifyer,    type: :string,     fix: "BLA"                },
          { name: :b,             type: :currency },
          { name: :c,             type: :float },
          { name: :d,             type: :integer },
          { name: :e,             type: :date },
]

empty_hash = { identifyer: "BLA", b: nil, c: nil, d: nil, e: nil }

empty_array = ["BLA", nil, nil, nil, nil]

filled_array = ["BLA", 20, 5.1, 10, Date.parse("12.10.1985")]

filled_csv   = "BLA;0,20;5,10;10;19851012\n"


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

  describe ".line_class_exists?" do
    it "should be true for a existing class" do
      Collmex::Api.line_class_exists?("Line").should be true
    end

    it "should be false for a non existant class" do
      Collmex::Api.line_class_exists?("asdasdasdasdaaBla").should be false
    end
  end

  describe ".stringify_field" do
    tests = [
              { type: :string,      input: "asd",             outcome: "asd" },
              { type: :string,      input: "",                outcome: "" },
              { type: :string,      input: nil,               outcome: "" },

              { type: :integer,     input: nil,               outcome: "" },
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
              { type: :currency,    input: -2.00,             outcome: "-2,00" },
              { type: :currency,    input: -2.90,             outcome: "-2,90" },
              { type: :currency,    input: -2.999,             outcome: "-3,00" },
              { type: :currency,    input: -102.90,           outcome: "-102,90" },    # <= WARNING


    ]
    tests.each do |test|
      it "should represent #{test[:type]} \"#{test[:input].inspect}\" as \"#{test[:outcome]}\"" do
        described_class.stringify(test[:input],test[:type]).should === test[:outcome]
      end
    end
  end


  describe ".parse_line" do
    context "when given a valid line" do
      context "as an array" do
        it "should instanciate an api line object" do
          line = Collmex::Api::Login.new([12,34]).to_a
          described_class.parse_line(line).should be_a Collmex::Api::Line
        end
      end
      context "as n csv string" do
        it "should instanciate an api line object" do
          line = Collmex::Api::Login.new([12,34]).to_csv
          described_class.parse_line(line).should be_a Collmex::Api::Line
        end
      end
    end

    context "when given an invalid line" do
      it "should throw an error" do
        line = ["OMG", 2,3,4,5,6]
        lambda { described_class.parse_line(line) }.should raise_error 'Could not find a Collmex::Api::Line class for "Omg" ("OMG")'
      end
    end
  end

  describe ".parse_field" do
    tests = [
              { type: :string,      input: "asd",             outcome: "asd" },
              { type: :string,      input: "2",               outcome: "2" },
              { type: :string,      input: "2",               outcome: "2" },
              { type: :string,      input: 2,                 outcome: "2" },
              { type: :string,      input: "-2.3",            outcome: "-2.3" },
              { type: :string,      input:  nil,              outcome: "" },

              { type: :date,        input: nil,               outcome: nil },
              { type: :date,        input: "19851012",        outcome: Date.parse("12.10.1985") },
              { type: :date,        input: "1985/10/12",      outcome: Date.parse("12.10.1985") },
              { type: :date,        input: "1985-10-12",      outcome: Date.parse("12.10.1985") },


              { type: :integer,     input: "2,3",             outcome: 2 },          # <= WARNING
              { type: :integer,     input: "2",               outcome: 2 },
              { type: :integer,     input: "2.2",             outcome: 2 },
              { type: :integer,     input: 2,                 outcome: 2 },
              { type: :integer,     input: 2.2,               outcome: 2 },
              { type: :integer,     input: nil,               outcome: nil },          # <= WARNING

              { type: :float,       input: "2",               outcome: 2.0 },
              { type: :float,       input: 2,                 outcome: 2.0 },
              { type: :float,       input: 2.2,               outcome: 2.2 },
              { type: :float,       input: "2,0",             outcome: 2.0 },
              { type: :float,       input: "2.0",             outcome: 2.0 },
              { type: :float,       input: "2,3",             outcome: 2.3 },
              { type: :float,       input: "-2,3",            outcome: -2.3 },
              { type: :float,       input: "2.2",             outcome: 2.2 },
              { type: :float,       input: nil,               outcome: nil },

              { type: :currency,    input: "2",               outcome: 2 },
              { type: :currency,    input: 0,                 outcome: 0 },
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
              { type: :currency,    input: nil,               outcome: nil },
              { type: :currency,    input: "-20.12",          outcome: -2012 },
              { type: :currency,    input: "-20.",            outcome: -2000 },
              { type: :currency,    input: "20.",             outcome: 2000 },
              { type: :currency,    input: ".20",             outcome: 20 },
              { type: :currency,    input: "-,20",            outcome: -20 },
              { type: :currency,    input: ",20",             outcome: 20 },

              { type: :currency,    input: "20,000",          outcome: 2000000 },
              { type: :currency,    input: "123,456",         outcome: 12345600 },
              { type: :currency,    input: "123,456,789",     outcome: 12345678900 },
              { type: :currency,    input: "123.456.789",     outcome: 12345678900 },
              { type: :currency,    input: "23.456.789",      outcome: 2345678900 },
              { type: :currency,    input: "-23.456.000",     outcome: -2345600000},
              { type: :currency,    input: "-23,456,000",     outcome: -2345600000 },

              { type: :currency,    input: "-23,456.00",      outcome: -2345600 },
              { type: :currency,    input: "23,456.13",       outcome: 2345613 },

              { type: :currency,    input: "21,000",          outcome: 2100000 },
              { type: :currency,    input: "12.345,20",       outcome: 1234520 },

            ]
    tests.each_with_index do |t,i|
      it "should parse #{t[:type]} value for \"#{t[:input]}\"" do
        described_class.parse_field( t[:input], t[:type]).should === t[:outcome]
      end
    end
  end
end

shared_examples_for "Collmex Api Command" do

  describe ".hashify" do

    it "should parse the fields" do
      string    = "BLA"
      integer   = 421
      float     = 123.23
      currency  = 200
      date      = Date.parse("12.10.1985")

      output = { identifyer: string, b: currency, c: float, d: integer, e: Date.parse("12.10.1985") }

      described_class.stub(:specification).and_return(sample_spec)
      Collmex::Api.stub(:parse_field).with(anything(),:string).and_return string
      Collmex::Api.stub(:parse_field).with(anything(),:float).and_return float
      Collmex::Api.stub(:parse_field).with(anything(),:integer).and_return integer
      Collmex::Api.stub(:parse_field).with(anything(),:currency).and_return currency
      Collmex::Api.stub(:parse_field).with(anything(),:date).and_return date

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
        described_class.hashify(testdata).should eql output
      end
    end

    it "should set default values when nothing given" do
      sample_default_spec = [
                        { name: :a,       type: :string,      default: "fixvalue" },
                        { name: :b,       type: :currency,    default: 899 },
                        { name: :c,       type: :integer,     default: 10 },
                        { name: :d,       type: :float,       default: 2.99 },
                    ]
      sample_default_outcome = {a: "fixvalue", b: 899, c: 10, d: 2.99}
      described_class.stub(:specification).and_return sample_default_spec
      described_class.hashify([]).should eql sample_default_outcome
    end

    it "should overwrite default values when data is given" do
      sample_default_spec = [
                        { name: :a,       type: :string,      default: "fixvalue" },
                        { name: :b,       type: :currency,    default: 899 },
                        { name: :c,       type: :integer,     default: 10 },
                        { name: :d,       type: :float,       default: 2.99 },
                    ]
      sample_default_outcome = {a: "asd", b: 12, c: 1, d: 1.0}
      described_class.stub(:specification).and_return sample_default_spec
      described_class.hashify({a: "asd", b: 12, c: 1, d: 1}).should eql sample_default_outcome
    end

    it "should ignore given values for fix-value-fields" do
      sample_fix_spec = [
                        { name: :a,       type: :string,      fix: "fixvalue" },
                        { name: :b,       type: :currency,    fix: 899 },
                        { name: :c,       type: :integer,     fix: 10 },
                        { name: :d,       type: :float,       fix: 2.99 },
                    ]
      sample_fix_outcome = {a: "fixvalue", b: 899, c: 10, d: 2.99}
      described_class.stub(:specification).and_return sample_fix_spec
      described_class.hashify([]).should eql sample_fix_outcome
    end
  end

  describe ".default_hash" do
    it "should hold a specification" do
      described_class.stub(:specification).and_return([])
      described_class.default_hash.should eql({})

      described_class.stub(:specification).and_return(sample_spec)
      described_class.default_hash.should eql(empty_hash)
    end
  end

  subject { described_class.new }

  it { should respond_to :to_csv }
  it { should respond_to :to_a }
  it { should respond_to :to_s }
  it { should respond_to :to_h }

  describe "#initialize" do
    it "should raise an error if the specification is empty and the class is not Collmex::Api::Line" do
      described_class.stub(:specification).and_return({})
      if described_class.name == "Collmex::Api::Line"
        lambda { described_class.new }.should_not raise_error
      else
        lambda { described_class.new }.should raise_error "#{described_class.name} has no specification"
      end
    end

    it "should set the instance_variable hash" do
      subject.instance_variable_get(:@hash).should be_a Hash
    end

    context "no params given" do
      it "should build the specified but empty hash" do
        described_class.stub(:default_hash).and_return(empty_hash)
        line = described_class.new
        line.to_h.should eql(empty_hash)
      end
    end

    context "something given" do
      it "should build the specified and filled hash" do
        input = {:a => "bla" }
        output = empty_hash.merge(input)

        described_class.stub(:default_hash).and_return(empty_hash)
        described_class.stub(:hashify).and_return(output)
        line = described_class.new(input)
        line.to_h.should eql (output)
      end
    end
  end

  describe "#to_csv" do
    it "should represent the request as csv" do
      described_class.stub(:specification).and_return(sample_spec)
      subject.instance_variable_set(:@hash, described_class.hashify(filled_array))
      subject.to_csv.should eql filled_csv
    end
  end

  describe "#to_h" do
    it "should return the hash" do
      h = { first: 1, second: 2 }
      subject.instance_variable_set(:@hash, h)
      subject.to_h.should eql h
    end
  end

  describe "#to_a" do
    it "should return the empty_hash translated to an array" do
      described_class.stub(:specification).and_return(sample_spec)
      subject.to_a.should eql empty_array
    end
  end


end

describe Collmex::Api::Line do
  it_behaves_like "Collmex Api Command"
end

describe Collmex::Api::Login do
  subject { Collmex::Api::Login.new({:username => "012", :password => "34"}) }
  it_behaves_like "Collmex Api Command"
  spec =
          [
              { name: :identifyer,    type: :string,    fix: "LOGIN"   },
              { name: :username,      type: :string },
              { name: :password,      type: :string }
          ]

  specify { described_class.specification.should eql spec }

  output = ["LOGIN", "012", "34"]
  specify { subject.to_a.should eql output }
end

describe Collmex::Api::CustomerGet do
  it_behaves_like "Collmex Api Command"

  spec =
          [
            { name: :identifyer       , type: :string    , fix: "CUSTOMER_GET"    },
            { name: :id               , type: :integer                            },
            { name: :company_id       , type: :integer   , default: 1             },
            { name: :searchtext       , type: :string                             },
            { name: :due_to_review    , type: :integer                            },
            { name: :zip_code         , type: :string                             },
            { name: :adress_group     , type: :integer                            },
            { name: :price_group      , type: :integer                            },
            { name: :discout_group    , type: :integer                            },
            { name: :agent            , type: :integer                            },
            { name: :only_changed     , type: :integer                            },
            { name: :system_name      , type: :string                             },
            { name: :inactive         , type: :integer                            },
          ]

  specify { described_class.specification.should eql spec }

  subject { described_class.new( {:customer_id => 9999} ) }

  output = ["CUSTOMER_GET", nil, 1, "", nil, "", nil, nil, nil, nil, nil, "", nil]

  specify { subject.to_a.should eql output }
end

describe Collmex::Api::AccdocGet do
  it_behaves_like "Collmex Api Command"

  spec =
          [
            { name: :identifyer       , type: :string    , fix: "ACCDOC_GET"     },
            { name: :company_id       , type: :integer   , default: 1             },
            { name: :business_year    , type: :integer                            },
            { name: :id               , type: :integer                            },
            { name: :account_id       , type: :integer                            },
            { name: :cost_unit        , type: :integer                            },
            { name: :customer_id      , type: :integer                            },
            { name: :provider_id      , type: :integer                            },
            { name: :asset_id         , type: :integer                            },
            { name: :invoice_id       , type: :integer                            },
            { name: :jorney_id        , type: :integer                            },
            { name: :text             , type: :string                             },
            { name: :date_start       , type: :date                               },
            { name: :date_end         , type: :date                               },
            { name: :cancellattion    , type: :integer                            },
            { name: :changed_only     , type: :integer                            },
            { name: :system_name      , type: :string                             },
          ]



  specify { described_class.specification.should eql spec }

  subject { described_class.new( {id: 1} ) }

  output = ["ACCDOC_GET", 1, nil, 1, nil, nil, nil, nil, nil, nil, nil, "", nil, nil, nil, nil, ""]

  specify { subject.to_a.should eql output }
end

describe Collmex::Api::AccbalGet do
  it_behaves_like "Collmex Api Command"

  spec =
        [
          {name: :identifyer,             type: :string, fix: "ACCBAL_GET"},
          {name: :company_id,             type: :integer, default: 1},
          {name: :fiscal_year,            type: :integer, default: Date.today.year},
          {name: :date_to,                type: :date},
          {name: :account_number,         type: :integer},
          {name: :account_group,          type: :integer}
        ]

  specify { described_class.specification.should eql spec }

  subject { described_class.new( {id: 1} ) }

  output = ["ACCBAL_GET", 1, Date.today.year, nil, nil, nil]

  specify { subject.to_a.should eql output }
end


describe Collmex::Api::Cmxknd do

  it_behaves_like "Collmex Api Command"
  spec =
          [
            { name: :identifyer       , type: :string    , fix: "CMXKND"          },
            { name: :customer_id      , type: :integer                            },
            { name: :company_id       , type: :integer   , default: 1             },
            { name: :salutation       , type: :string                             },
            { name: :title            , type: :string                             },
            { name: :firstname        , type: :string                             },
            { name: :lastname         , type: :string                             },
            { name: :company          , type: :string                             },
            { name: :department       , type: :string                             },
            { name: :street           , type: :string                             },
            { name: :zipcode          , type: :string                             },
            { name: :city             , type: :string                             },
            { name: :annotation       , type: :string                             },
            { name: :inactive         , type: :integer                            },
            { name: :country          , type: :string                             },
            { name: :phone            , type: :string                             },
            { name: :fax              , type: :string                             },
            { name: :email            , type: :string                             },
            { name: :account_id       , type: :string                             },
            { name: :blz              , type: :string                             },
            { name: :iban             , type: :string                             },
            { name: :bic              , type: :string                             },
            { name: :bank_name        , type: :string                             },
            { name: :vat_id           , type: :string                             },
            { name: :ust_ldnr         , type: :string                             },
            { name: :payment_condition, type: :integer                            },
            { name: :dscout_group     , type: :integer                            },
            { name: :deliver_conditions, type: :string                            },
            { name: :deliver_conditions_additions, type: :string                  },
            { name: :output_media     , type: :integer                            },
            { name: :account_owner    , type: :string                             },
            { name: :address_group    , type: :integer                            },
            { name: :ebay_member      , type: :string                             },
            { name: :price_group      , type: :integer                            },
            { name: :currency         , type: :string                             },
            { name: :agent            , type: :integer                            },
            { name: :cost_unit        , type: :string                             },
            { name: :due_to           , type: :date                               },
            { name: :delivery_ban     , type: :integer                            },
            { name: :building_servant , type: :integer                            },
            { name: :account_id_at_customer, type: :string                        },
            { name: :output_language  , type: :integer                            },
            { name: :email_cc         , type: :string                             },
            { name: :phone_2          , type: :string                             },
          ]

  specify { described_class.specification.should eql spec }

  subject { described_class.new( {id: 1} ) }

  output = ["CMXKND", nil, 1, "", "", "", "", "", "", "", "", "", "", nil, "", "", "", "", "", "", "", "", "", "", "", nil, nil, "", "", nil, "", nil, "", nil, "", nil, "", nil, nil, nil, "", nil, "", ""]

  specify { subject.to_a.should eql output }
end


describe Collmex::Api::Message do

  it_behaves_like "Collmex Api Command"

  spec =
          [
            { name: :identifyer       , type: :string    , fix: "MESSAGE"         },
            { name: :type             , type: :string                             },
            { name: :id               , type: :integer                            },
            { name: :text             , type: :string                             },
            { name: :line             , type: :integer                            },
          ]

  specify { described_class.specification.should eql spec }

  subject { described_class.new(  ) }

  output = ["MESSAGE", "", nil, "", nil]

  specify { subject.to_a.should eql output }

  context "success" do
    subject { described_class.new(type: "S") }
    specify do
      subject.success?.should eql true
      subject.result.should eql :success
    end
  end

  context "warning" do
    subject { described_class.new(type: "W") }
    specify do
      subject.success?.should eql false
      subject.result.should eql :warning
    end
  end

  context "error" do
    subject { described_class.new(type: "E") }
    specify do
      subject.success?.should eql false
      subject.result.should eql :error
    end
  end

  context "undefined" do
    subject { described_class.new() }
    specify do
      subject.success?.should eql false
      subject.result.should eql :undefined
    end
  end


end


describe Collmex::Api::Accdoc do   # fixme ACCDOC

  it_behaves_like "Collmex Api Command"

  spec =
          [
            { name: :identifyer       , type: :string    , fix: "ACCDOC"          },
            { name: :company_id       , type: :integer   , default: 1             },
            { name: :business_year    , type: :integer                            },
            { name: :id               , type: :integer                            },
            { name: :accdoc_date      , type: :date                               },
            { name: :accounted_date   , type: :date                               },
            { name: :test             , type: :string                             },
            { name: :position_id      , type: :integer                            },
            { name: :account_id       , type: :integer                            },
            { name: :account_name     , type: :string                             },
            { name: :should_have      , type: :integer                            },
            { name: :amount           , type: :currency                           },
            { name: :customer_id      , type: :integer                            },
            { name: :customer_name    , type: :string                             },
            { name: :provider_id      , type: :integer                            },
            { name: :provider_name    , type: :string                             },
            { name: :asset_id         , type: :integer                            },
            { name: :asset_name       , type: :string                             },
            { name: :canceled_accdoc  , type: :integer                            },
            { name: :cost_unit        , type: :string                             },
            { name: :invoice_id       , type: :string                             },
            { name: :customer_order_id, type: :integer                            },
            { name: :jorney_id        , type: :integer                            },
            { name: :belongs_to_id    , type: :integer                            },
            { name: :belongs_to_year  , type: :integer                            },
            { name: :belongs_to_pos   , type: :integer                            },
          ]



  specify { described_class.specification.should eql spec }

  subject { described_class.new( {id: 1} ) }

  output = ["ACCDOC", 1, nil, 1, nil, nil, "", nil, nil, "", nil, nil, nil, "", nil, "", nil, "", nil, "", "", nil, nil, nil, nil, nil]

  specify { subject.to_a.should eql output }
end


describe Collmex::Api::AccBal do

  it_behaves_like "Collmex Api Command"

  spec =
          [
            {name: :identifyer,      type: :string, fix: "ACC_BAL"},
            {name: :account_number,  type: :integer},
            {name: :account_name,    type: :string},
            {name: :account_balance, type: :currency}
          ]

  specify { described_class.specification.should eql spec }

  subject { described_class.new( {id: 1} ) }

  output = ["ACC_BAL", nil, "", nil]

  specify { subject.to_a.should eql output }
end


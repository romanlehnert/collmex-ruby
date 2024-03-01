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
      expect(described_class.is_a_collmex_api_line_obj?(a)).to be_falsey
    end

    it "should succeed for a Collmex::Api Object" do
      b = Collmex::Api::AccdocGet.new()
      expect(described_class.is_a_collmex_api_line_obj?(b)).to be_truthy
    end
  end

  describe ".line_class_exists?" do
    it "should be true for a existing class" do
      expect(Collmex::Api.line_class_exists?("Line")).to be true
    end

    it "should be false for a non existant class" do
      expect(Collmex::Api.line_class_exists?("asdasdasdasdaaBla")).to be false
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

              { type: :float,       input: nil,               outcome: "" },
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
        expect(described_class.stringify(test[:input],test[:type])).to be === test[:outcome]
      end
    end
  end


  describe ".parse_line" do
    context "when given a valid line" do
      context "as an array" do
        it "should instanciate an api line object" do
          line = Collmex::Api::Login.new([12,34]).to_a
          expect(described_class.parse_line(line)).to be_a Collmex::Api::Line
        end
      end
      context "as n csv string" do
        it "should instanciate an api line object" do
          line = Collmex::Api::Login.new([12,34]).to_csv
          expect(described_class.parse_line(line)).to be_a Collmex::Api::Line
        end
      end
    end

    context "when given an invalid line" do
      it "should throw an error" do
        line = ["OMG", 2,3,4,5,6]
        expect { described_class.parse_line(line) }.to raise_error 'Could not find a Collmex::Api::Line class for "Omg" ("OMG")'
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
        expect(described_class.parse_field( t[:input], t[:type])).to be === t[:outcome]
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

      allow(described_class).to receive(:specification).and_return(sample_spec)
      allow(Collmex::Api).to receive(:parse_field).with(anything(),:string).and_return string
      allow(Collmex::Api).to receive(:parse_field).with(anything(),:float).and_return float
      allow(Collmex::Api).to receive(:parse_field).with(anything(),:integer).and_return integer
      allow(Collmex::Api).to receive(:parse_field).with(anything(),:currency).and_return currency
      allow(Collmex::Api).to receive(:parse_field).with(anything(),:date).and_return date

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
        expect(described_class.hashify(testdata)).to eql output
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
      allow(described_class).to receive(:specification).and_return sample_default_spec
      expect(described_class.hashify([])).to eql sample_default_outcome
    end

    it "should overwrite default values when data is given" do
      sample_default_spec = [
                        { name: :a,       type: :string,      default: "fixvalue" },
                        { name: :b,       type: :currency,    default: 899 },
                        { name: :c,       type: :integer,     default: 10 },
                        { name: :d,       type: :float,       default: 2.99 },
                    ]
      sample_default_outcome = {a: "asd", b: 12, c: 1, d: 1.0}
      allow(described_class).to receive(:specification).and_return sample_default_spec
      expect(described_class.hashify({a: "asd", b: 12, c: 1, d: 1})).to eql sample_default_outcome
    end

    it "should ignore given values for fix-value-fields" do
      sample_fix_spec = [
                        { name: :a,       type: :string,      fix: "fixvalue" },
                        { name: :b,       type: :currency,    fix: 899 },
                        { name: :c,       type: :integer,     fix: 10 },
                        { name: :d,       type: :float,       fix: 2.99 },
                    ]
      sample_fix_outcome = {a: "fixvalue", b: 899, c: 10, d: 2.99}
      allow(described_class).to receive(:specification).and_return sample_fix_spec
      expect(described_class.hashify([])).to eql sample_fix_outcome
    end
  end

  describe ".default_hash" do
    it "should hold a specification" do
      allow(described_class).to receive(:specification).and_return([])
      expect(described_class.default_hash).to eql({})

      allow(described_class).to receive(:specification).and_return(sample_spec)
      expect(described_class.default_hash).to eql(empty_hash)
    end
  end

  subject { described_class.new }

  it { is_expected.to respond_to :to_csv }
  it { is_expected.to respond_to :to_a }
  it { is_expected.to respond_to :to_s }
  it { is_expected.to respond_to :to_h }

  describe "#initialize" do
    it "should raise an error if the specification is empty and the class is not Collmex::Api::Line" do
      allow(described_class).to receive(:specification).and_return({})
      if described_class.name == "Collmex::Api::Line"
        expect { described_class.new }.not_to raise_error
      else
        expect { described_class.new }.to raise_error "#{described_class.name} has no specification"
      end
    end

    it "should set the instance_variable hash" do
      expect(subject.instance_variable_get(:@hash)).to be_a Hash
    end

    context "no params given" do
      it "should build the specified but empty hash" do
        allow(described_class).to receive(:default_hash).and_return(empty_hash)
        line = described_class.new
        expect(line.to_h).to eql(empty_hash)
      end
    end

    context "something given" do
      it "should build the specified and filled hash" do
        input = {:a => "bla" }
        output = empty_hash.merge(input)

        allow(described_class).to receive(:default_hash).and_return(empty_hash)
        allow(described_class).to receive(:hashify).and_return(output)
        line = described_class.new(input)
        expect(line.to_h).to eql (output)
      end
    end
  end

  describe "#to_csv" do
    it "should represent the request as csv" do
      allow(described_class).to receive(:specification).and_return(sample_spec)
      subject.instance_variable_set(:@hash, described_class.hashify(filled_array))
      expect(subject.to_csv).to eql filled_csv
    end
  end

  describe "#to_h" do
    it "should return the hash" do
      h = { first: 1, second: 2 }
      subject.instance_variable_set(:@hash, h)
      expect(subject.to_h).to eql h
    end
  end

  describe "#to_a" do
    it "should return the empty_hash translated to an array" do
      allow(described_class).to receive(:specification).and_return(sample_spec)
      expect(subject.to_a).to eql empty_array
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

  specify { expect(described_class.specification).to eql spec }

  output = ["LOGIN", "012", "34"]
  specify { expect(subject.to_a).to eql output }
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

  specify { expect(described_class.specification).to eql spec }

  subject { described_class.new( {:customer_id => 9999} ) }

  output = ["CUSTOMER_GET", nil, 1, "", nil, "", nil, nil, nil, nil, nil, "", nil]

  specify { expect(subject.to_a).to eql output }
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



  specify { expect(described_class.specification).to eql spec }

  subject { described_class.new( {id: 1} ) }

  output = ["ACCDOC_GET", 1, nil, 1, nil, nil, nil, nil, nil, nil, nil, "", nil, nil, nil, nil, ""]

  specify { expect(subject.to_a).to eql output }
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

  specify { expect(described_class.specification).to eql spec }

  subject { described_class.new( {id: 1} ) }

  output = ["ACCBAL_GET", 1, Date.today.year, nil, nil, nil]

  specify { expect(subject.to_a).to eql output }
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
            { name: :sepa_mandate_reference, type: :string                        },
            { name: :sepa_mandate_signature_date, type: :date                     },
            { name: :dunning_block    , type: :integer                            },
          ]

  specify { expect(described_class.specification).to eql spec }

  subject { described_class.new( {id: 1} ) }

  output = ["CMXKND", nil, 1, "", "", "", "", "", "", "", "", "", "", nil, "", "", "", "", "", "", "", "", "", "", "", nil, nil, "", "", nil, "", nil, "", nil, "", nil, "", nil, nil, nil, "", nil, "", "", "", nil, nil]

  specify { expect(subject.to_a).to eql output }
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

  specify { expect(described_class.specification).to eql spec }

  subject { described_class.new(  ) }

  output = ["MESSAGE", "", nil, "", nil]

  specify { expect(subject.to_a).to eql output }

  context "success" do
    subject { described_class.new(type: "S") }
    specify do
      expect(subject.success?).to eql true
      expect(subject.result).to eql :success
    end
  end

  context "warning" do
    subject { described_class.new(type: "W") }
    specify do
      expect(subject.success?).to eql false
      expect(subject.result).to eql :warning
    end
  end

  context "error" do
    subject { described_class.new(type: "E") }
    specify do
      expect(subject.success?).to eql false
      expect(subject.result).to eql :error
    end
  end

  context "undefined" do
    subject { described_class.new() }
    specify do
      expect(subject.success?).to eql false
      expect(subject.result).to eql :undefined
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



  specify { expect(described_class.specification).to eql spec }

  subject { described_class.new( {id: 1} ) }

  output = ["ACCDOC", 1, nil, 1, nil, nil, "", nil, nil, "", nil, nil, nil, "", nil, "", nil, "", nil, "", "", nil, nil, nil, nil, nil]

  specify { expect(subject.to_a).to eql output }
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

  specify { expect(described_class.specification).to eql spec }

  subject { described_class.new( {id: 1} ) }

  output = ["ACC_BAL", nil, "", nil]

  specify { expect(subject.to_a).to eql output }
end

describe Collmex::Api::Cmxums do

  it_behaves_like "Collmex Api Command"
  spec =
    [
      { name: :_1_identifyer, type: :string, fix: "CMXUMS"}, # 1
      { name: :_2_customer_id, type: :integer},
      { name: :_3_company_id, type: :integer, default: 1},
      { name: :_4_receipt_date, type: :date },
      { name: :_5_receipt_number, type: :string }, # 5
      { name: :_6_net_value_full_tax, type: :currency },
      { name: :_7_tax_value_full_tax, type: :currency },
      { name: :_8_net_value_half_tax, type: :currency },
      { name: :_9_tax_value_half_tax, type: :currency },
      { name: :_10_net_value_inter_eu_trade, type: :currency }, # 10
      { name: :_11_net_value_export, type: :currency },
      { name: :_12_account_revenue_tax_free, type: :integer },
      { name: :_13_value_revenue_tax_free, type: :currency },
      { name: :_14_currency_code, type: :string },
      { name: :_15_contra_account, type: :integer }, # 15
      { name: :_16_receipt_type, type: :integer, default: 0 },
      { name: :_17_receipt_text, type: :string },
      { name: :_18_payment_term, type: :integer },
      { name: :_19_account_full_tax, type: :integer },
      { name: :_20_account_half_tax, type: :integer }, # 20
      { name: :_21_reserved21, type: :string },
      { name: :_22_reserved22, type: :string },
      { name: :_23_storno, type: :integer },
      { name: :_24_final_receipt, type: :string },
      { name: :_25_revenue_type, type: :integer }, # 25
      { name: :_26_system_name, type: :string },
      { name: :_27_charge_against_receipt_number, type: :string },
      { name: :_28_cost_center, type: :string }
    ]

  specify { expect(described_class.specification).to eql spec }

  subject { described_class.new( {id: 1} ) }

  output = ["CMXUMS", nil, 1, nil, "", nil, nil, nil, nil, nil, nil, nil, nil, "", nil, 0, "", nil, nil, nil, "", "", nil, "", nil, "", "", ""]

  specify { expect(subject.to_a).to eql output }
end

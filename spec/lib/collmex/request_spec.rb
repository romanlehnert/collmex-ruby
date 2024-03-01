require "spec_helper"

describe Collmex::Request do

  describe ".run" do
    it "should return an instance of Colmex::Request" do
      allow_any_instance_of(Collmex::Request).to receive(:execute)
      expect(Collmex::Request.run).to be_a Collmex::Request
    end

    it "should execute a given block" do
      allow_any_instance_of(Collmex::Request).to receive(:execute)
      expect_any_instance_of(Collmex::Request).to receive(:dump).with("arr").and_return("blaaaa")
      Collmex::Request.run do
        dump "arr"
      end
    end
  end

  describe ".uri" do
    subject { Collmex::Request.uri }
    specify { expect(subject.to_s).to eql "https://www.collmex.de/cgi-bin/cgi.exe?#{Collmex.customer_id},0,data_exchange" }
  end

  subject { described_class.new }
  specify { expect(subject).to be_a Collmex::Request }



  describe "#initialize" do

    it "should raise an error if no credentials given" do
      Collmex.reset_login_data
      expect { Collmex::Request.new }.to raise_error "No credentials for collmex given"
    end

    it "should add the Login command to its own queue" do
      request = Collmex::Request.new
      expect(request.commands.count).to eql 1
    end
  end

  describe "#add_command" do

    it "should add the given command to its command array" do
      request = Collmex::Request.new 
      expect(request).to be_a Collmex::Request
      
      request.commands = Array.new
      request.add_command "asd"
      expect(request.commands.count).to eql 1
    end
  end

  describe "#classfy" do

    subject { Collmex::Request }

    specify do
      expect(subject.classify(:accdoc_get)).to eql "AccdocGet"
      expect(subject.classify(:accDoc_get)).to eql "AccdocGet"
    end
  end

  describe "#enqueue" do

    context "given a symbol command" do
      let(:request) { Collmex::Request.new }

      it "should return a command object" do
        expect(request.enqueue(:accdoc_get)).to be_a Collmex::Api::AccdocGet
      end

      it "should enqueue the given comands" do 
        initial_count = request.commands.count 
        request.enqueue :accdoc_get 
        request.enqueue :accdoc_get, :accdoc_id => 1
        expect(request.commands.count).to equal (initial_count + 2)
      end
    end

    context "given a collmex api line object" do 

      let(:request) { Collmex::Request.new }

      it "should retun the command object" do
        cmd_obj = Collmex::Api::AccdocGet.new()
        expect(request.enqueue(cmd_obj)).to eql cmd_obj
      end

      it "should enqueue the command object" do 
        initial_count = request.commands.count
        cmd_obj = Collmex::Api::AccdocGet.new()
        request.enqueue cmd_obj
        expect(request.commands.count).to eql (initial_count + 1)
        expect(request.commands.last).to eql cmd_obj
      end
    end
        
  end


  describe ".execute" do

    before(:each) do 
      allow(Net::HTTP).to receive(:new).and_return(http)
      allow(Net::HTTP).to receive(:request_post).and_return(response)
      allow(Collmex::Api).to receive(:parse_line)
    end

    let(:http) do
      http = double(Net::HTTP)
      allow(http).to receive("use_ssl=")
      allow(http).to receive("verify_mode=")
      allow(http).to receive(:request_post).and_return(response)
      http
    end

    let(:response) do 
      response = double(Net::HTTPOK)
      allow(response).to receive(:body).and_return("fuckmehard")
      allow(response).to receive(:code).and_return(200)
      response
    end

    it "should create an instance of net::http" do
      expect(Net::HTTP).to receive(:new).and_return(http)
      subject.execute
    end

    it "should use ssl" do
      expect(http).to receive("use_ssl=").with(true)
      subject.execute
    end

    it "should not verify ssl" do
      expect(http).to receive("verify_mode=").with(OpenSSL::SSL::VERIFY_NONE)
      subject.execute
    end

    it "shoud do the post_request" do
      expect(http).to receive(:request_post).with(anything,anything,{"Content-Type" => "text/csv"}).and_return(response)
      subject.execute
    end

    context "with a working connection" do
      
      it "should parse the response" do
        allow(subject).to receive(:parse_response).and_return( [Collmex::Api::Accdoc.new])
        expect(subject).to receive(:parse_response)
        subject.execute
      end
      it "the response should be encoded in utf-8" do
        string = "Allgemeiner Gesch\xE4ftspartne".force_encoding("ASCII-8BIT")
        allow(response).to receive(:body).and_return(string)
        subject.execute      
      
        expect(subject.instance_variable_get(:@raw_response)[:string].encoding.to_s).to eql "UTF-8"
      end

    end

  end

end

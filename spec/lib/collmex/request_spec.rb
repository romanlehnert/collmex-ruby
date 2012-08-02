require "spec_helper"

describe Collmex::Request do

  describe ".run" do
    it "should return an instance of Colmex::Request" do
      Collmex::Request.any_instance.stub(:execute)
      Collmex::Request.run.should be_a Collmex::Request
    end

    it "should execute a given block" do
      Collmex::Request.any_instance.stub(:execute)
      Collmex::Request.any_instance.should_receive(:dump).with("arr").and_return("blaaaa")
      Collmex::Request.run do
        dump "arr"
      end
    end
  end

  describe ".uri" do
    subject { Collmex::Request.uri }
    specify { subject.to_s.should eql "https://www.collmex.de/cgi-bin/cgi.exe?#{Collmex.customer_id},0,data_exchange" }
  end

  subject { described_class.new }
  specify { subject.should be_a Collmex::Request }



  describe "#initialize" do

    it "should raise an error if no credentials given" do
      Collmex.reset_login_data
      lambda { Collmex::Request.new }.should raise_error "No credentials for collmex given"
    end

    it "should add the Login command to its own queue" do
      request = Collmex::Request.new
      request.commands.count.should eql 1
    end
  end

  describe "#add_command" do

    it "should add the given command to its command array" do
      request = Collmex::Request.new 
      request.should be_a Collmex::Request
      
      request.commands = Array.new
      request.add_command "asd"
      request.commands.count.should eql 1
    end
  end

  describe "#classfy" do

    subject { Collmex::Request }

    specify do
      subject.classify(:accdoc_get).should eql "AccdocGet"
      subject.classify(:accDoc_get).should eql "AccdocGet"
    end
  end

  describe "#enqueue" do

    context "given a symbol command" do
      let(:request) { Collmex::Request.new }

      it "should return a command object" do
        request.enqueue(:accdoc_get).should be_a Collmex::Api::AccdocGet
      end

      it "should enqueue the given comands" do 
        initial_count = request.commands.count 
        request.enqueue :accdoc_get 
        request.enqueue :accdoc_get, :accdoc_id => 1
        request.commands.count.should equal (initial_count + 2)
      end
    end

    context "given a collmex api line object" do 

      let(:request) { Collmex::Request.new }

      it "should retun the command object" do
        cmd_obj = Collmex::Api::AccdocGet.new()
        request.enqueue(cmd_obj).should eql cmd_obj
      end

      it "should enqueue the command object" do 
        initial_count = request.commands.count
        cmd_obj = Collmex::Api::AccdocGet.new()
        request.enqueue cmd_obj
        request.commands.count.should eql (initial_count + 1)
        request.commands.last.should eql cmd_obj
      end
    end
        
  end


  describe ".execute" do

    before(:each) do 
      Net::HTTP.stub(:new).and_return(http)
      Net::HTTP.stub(:request_post).and_return(response)
      Collmex::Api.stub(:parse_line)
    end

    let(:http) do
      http = mock(Net::HTTP)
      http.stub("use_ssl=")
      http.stub("verify_mode=")
      http.stub(:request_post).and_return(response)
      http
    end

    let(:response) do 
      response = mock(Net::HTTPOK)
      response.stub(:body).and_return("fuckmehard")
      response.stub(:code).and_return(200)
      response
    end

    it "should create an instance of net::http" do
      Net::HTTP.should_receive(:new).and_return(http)
      subject.execute
    end

    it "should use ssl" do
      http.should_receive("use_ssl=").with(true)
      subject.execute
    end

    it "should not verify ssl" do
      http.should_receive("verify_mode=").with(OpenSSL::SSL::VERIFY_NONE)
      subject.execute
    end

    it "shoud do the post_request" do
      http.should_receive(:request_post).with(anything,anything,{"Content-Type" => "text/csv"}).and_return(response)
      subject.execute
    end

    context "with a working connection" do
      
      it "should parse the response" do
        subject.stub(:parse_response).and_return( [Collmex::Api::Accdoc.new])
        subject.should_receive(:parse_response)
        subject.execute
      end
      it "the response should be encoded in utf-8" do
        string = "Allgemeiner Gesch\xE4ftspartne".force_encoding("ASCII-8BIT")
        response.stub(:body).and_return(string)
        subject.execute      
      
        subject.instance_variable_get(:@raw_response)[:string].encoding.to_s.should eql "UTF-8"
      end

    end

  end

end

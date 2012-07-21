require "spec_helper"

describe Collmex::Request do

  describe "#uri" do
    subject { Collmex::Request.uri }
    specify { subject.to_s.should eql "https://www.collmex.de/cgi-bin/cgi.exe?000000,0,data_exchange" }
  end

  subject { described_class.new }
  specify { subject.should be_a Collmex::Request }

  describe "instanitiation" do

    it "should add the Login command to its own queue" do

      request = Collmex::Request.new
    
      request.commands.count.should eql 1

    end
  end

  describe ".add_command" do

    it "should add the given command to its command array" do
      request = Collmex::Request.new 
      request.should be_a Collmex::Request
      
      request.commands = Array.new
      request.add_command "asd"
      request.commands.count.should eql 1
    end
  end

  describe ".do" do

    before(:each) do 
      Net::HTTP.stub(:new).and_return(http)
      Net::HTTP.stub(:request_post).and_return(response)
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
      response
    end

    it "should create a instance of net::http" do
      Net::HTTP.should_receive(:new).and_return(http)
      subject.do
    end

    it "should use ssl" do
      http.should_receive("use_ssl=").with(true)
      subject.do
    end

    it "should not verify ssl" do
      http.should_receive("verify_mode=").with(OpenSSL::SSL::VERIFY_NONE)
      subject.do
    end

    it "shoud do the post_request" do
      http.should_receive(:request_post).with(anything,anything,{"Content-Type" => "text/csv"}).and_return(response)
      subject.do
    end

    context "with a working connection" do
      
      it "should return the response body" do
        subject.do.should eql "fuckmehard" 
      end

      it "the response should be encoded in utf-8" do
        string = "Allgemeiner Gesch\xE4ftspartne".force_encoding("ASCII-8BIT")
        response.stub(:body).and_return(string)
        subject.do.encoding.to_s.should eql "UTF-8"
      end

    end

  end

end

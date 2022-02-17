require "net/http"
require "uri"

module Collmex
  class Request
    attr_accessor :commands, :http
    attr_accessor :debug

    def self.run(&block)
      Request.new.tap do |request|
        request.instance_eval &block if block_given?
        request.execute
      end
    end


    def self.classify(term)
      term.to_s.split("_").collect(&:capitalize).join
    end

    def enqueue(command, args = {})
      if command.is_a? Symbol
        add_command Collmex::Api::const_get(self.class.classify(command)).new(args)
      elsif Collmex::Api.is_a_collmex_api_line_obj?(command)
        add_command command
      else
        return false
      end
    end

    def initialize
      @commands     = []
      @raw_response = {}

      if Collmex.username.nil? || Collmex.password.nil? || Collmex.customer_id.nil?
        raise "No credentials for collmex given"
      else
        add_command Collmex::Api::Login.new({username: Collmex.username, password: Collmex.password})
      end
    end

    def add_command(cmd)
      @commands << cmd
      cmd
    end

    def self.uri
      URI.parse "https://www.collmex.de/cgi-bin/cgi.exe\?#{Collmex.customer_id},0,data_exchange"
    end

    def self.header_attributes
      {"Content-Type" => "text/csv"}
    end

    def payload
      @commands.map { |c| c.to_csv }.join
    end

    def parse_response
      @response = @raw_response[:array].map { |l| Collmex::Api.parse_line(l) }
      @response
    end

    def raw_response
      @raw_response
    end

    def response
      @response
    end

    def execute
      @http = Net::HTTP.new(Collmex::Request.uri.host, Collmex::Request.uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # http://www.collmex.de/faq.html#zeichensatz_import
      encoded_body = payload.encode("ISO8859-1", undef: :replace) # Do not blow up on undefined characters in ISO8859-1
      response = @http.request_post(Collmex::Request.uri.request_uri, encoded_body, Collmex::Request.header_attributes)
      response.body.force_encoding("ISO8859-1") if response.body.encoding == Encoding::BINARY

      @raw_response[:string] = response.body.encode("UTF-8")

      begin
        @raw_response[:array]  = CSV.parse(@raw_response[:string], Collmex.csv_opts)
      rescue => e
        STDERR.puts "CSV.parse failed with string: #{@raw_response[:string]}" if self.debug
        raise e
      end

      parse_response
    end
  end
end

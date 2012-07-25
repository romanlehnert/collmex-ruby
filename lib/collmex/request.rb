require "net/http"
require "uri"

module Collmex
  class Request

    attr_accessor :commands

    def initialize(add_login = true)
      @commands = Array.new
      login = Collmex::Api::Login.new({username: Collmex.username, password: Collmex.password})
      self.add_command(login) if add_login
    end

    def add_command(cmd)
      @commands << cmd
    end
    
    def self.uri
      URI.parse "https://www.collmex.de/cgi-bin/cgi.exe\?#{Collmex.customer_id},0,data_exchange"
    end

    def self.header_attributes
      {"Content-Type" => "text/csv"}
    end

    def execute(payload = "")

      @http = Net::HTTP.new(Collmex::Request.uri.host, Collmex::Request.uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      payload = @commands.join


      response = @http.request_post(Collmex::Request.uri.request_uri, payload, Collmex::Request.header_attributes)
      response.body.force_encoding("ISO8859-1") if response.body.encoding.to_s == "ASCII-8BIT"
      return response.body.encode("UTF-8")
    end

  end
end

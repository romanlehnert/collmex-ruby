require "net/http"
require "uri"

module Collmex
  class Request

    
    def self.uri
      URI.parse "https://www.collmex.de/cgi-bin/cgi.exe\?#{Collmex.customer_id},0,data_exchange"
    end

    def self.header_attributes
      {"Content-Type" => "text/csv"}
    end

    def do(payload = "")
      http = Net::HTTP.new(self.class.uri.request_uri)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = http.request_post(Collmex::Request.uri,payload,Collmex::Request.header_attributes)

      response.body.force_encoding("ISO8859-1") if response.body.encoding.to_s == "ASCII-8BIT"
      response.body.encode("UTF-8")
    end

  end
end

require "csv"

module Collmex
  class Api

    class Template

      attr_accessor :opts

      def csv_opts
        {
          :col_sep => ";"
        }
      end

      def to_csv
        CSV.generate_line(self.to_a, self.csv_opts)
      end

      def to_s
        "Collex API Row: " + self.to_csv
      end
    end

    class Login < Template

      def initialize( opts = {:username => "", :password => ""})
        self.opts = opts
      end

      def to_a
        ["LOGIN", opts[:username], opts[:password], "asd"]
      end
    end

    class CustomerGet < Template

      def initialize( opts = {:customer_id => nil } )
        self.opts = opts
      end

      def to_a
        ["CUSTOMER_GET", opts[:customer_id], 1]
      end

    end


  end
end

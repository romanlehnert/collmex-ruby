require "csv"

module Collmex
  class Api

    def self.is_a_collmex_command_obj? obj
      obj.class.name =~ /Collmex\:\:Api/
    end

    class Template

      attr_accessor :opts

      def to_csv
        CSV.generate_line(self.to_a, Collmex.csv_opts)
      end

      def to_s
        self.to_csv
      end
    end

    class Login < Template

      def initialize( opts = {:username => "", :password => ""})
        self.opts = opts
      end

      def to_a
        ["LOGIN", opts[:username], opts[:password]]
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

    class AccdocGet < Template
      def initialize( opts = {:accdoc_id => nil } )
        self.opts = opts
      end
      def to_a
        ["ACCDOC_GET", 1, nil, opts[:accdoc_id] ]
      end
    end


  end
end

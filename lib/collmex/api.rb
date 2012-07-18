require "csv"

module Collmex
  class Api

    class Template
      def csv_opts
        {
          :col_sep => ";"
        }
      end

      def to_csv
        CSV.generate_line(self.to_a, self.csv_opts)
      end
    end

    class Login < Template

      attr_accessor :username, :password

      def initialize(params = {:username => "", :password => ""})
        self.username = params[:username]
        self.password = params[:password]
      end

      def to_a
        ["LOGIN", username, password, "asd"]
      end
    end
  end
end

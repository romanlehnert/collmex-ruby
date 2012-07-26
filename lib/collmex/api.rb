require "csv"

module Collmex
  class Api

    def self.is_a_collmex_api_line_obj? obj
      obj.class.name =~ /Collmex\:\:Api/
    end

    def self.parse_field(value, type, opts = nil)
      case type
        when :string    then value.to_s
        when :int       then value.to_i
        when :integer   then value.to_i
        when :float     then value.to_s.gsub(',','.').to_f
        when :currency  then Collmex::Api.parse_currency(value)
        else value
      end
    end

    def self.parse_currency(str)
      str = str.to_s
      case str
      when /\A-?\d*[\,|.]\d{0,2}\z/ then (str.gsub(',','.').to_f * 100).to_i
      when /\A-?\d+\z/ then str.to_i
      when /\A-?((\d){1,3})*([\.]\d{3})+([,]\d{2})\z/ then (str.gsub('.','').gsub(',','.').to_f * 100).to_i
      when /\A-?((\d){1,3})*([\,]\d{3})+([.]\d{2})\z/ then (str.gsub(',','').to_f * 100).to_i
      when /\A-?((\d){1,3})*([\.\,]\d{3})+\z/ then str.gsub(',','').gsub('.','').to_i
      else str.to_i
      end
    end

    def self.stringify(data, type)
      case type
      when :integer then data.to_i.to_s
      when :string then data.to_s
      when :float then sprintf("%.2f",data).gsub('.',',')
      when :currency then Collmex::Api.stringify_currency(data)
      end
    end
        
    def self.stringify_currency(data)
      case
      when data.is_a?(Integer) then sprintf("%.2f",(data.to_f / 100)).gsub('.',',')
      when data.is_a?(Float) then sprintf("%.2f",(data.to_f / 100)).gsub('.',',')
      when data.is_a?(String) 
        int = self.parse_currency(data) 
        sprintf("%.2f",(int.to_f / 100)).gsub('.',',')
      else data
      end
    end

    class Line

      def self.specification
        {}
      end

      def self.default_hash
        hash = {}
        self.specification.each_with_index do |field_spec, index| 
          hash[field_spec[:name]] = Collmex::Api.parse_field(nil, field_spec[:type])
        end
        hash
      end


      def self.hashify(data)

        hash = {}

        fields_spec = self.specification

        if data.is_a? Array
          fields_spec.each_with_index do |field_spec, index| 
            hash[field_spec[:name]] = Collmex::Api.parse_field(data[index], field_spec[:type])
          end
        elsif data.is_a? Hash
          fields_spec.each_with_index do |field_spec, index|
            hash[field_spec[:name]] = Collmex::Api.parse_field(data[field_spec[:name]], field_spec[:type])
          end
        elsif data.is_a?(String) && parsed = CSV.parse_line(data,Collmex.csv_opts)
          fields_spec.each_with_index do |field_spec, index| 
            hash[field_spec[:name]] = Collmex::Api.parse_field(parsed[index], field_spec[:type])
          end
        end
        
        hash
      end

      attr_accessor :opts

      def initialize(arg = nil) 
        @hash = self.class.default_hash
        @hash = @hash.merge(self.class.hashify(arg)) if !arg.nil?
      end

     
      def to_a
        array = []
        self.class.specification.each do |spec|
          array << @hash[spec[:name]]
        end
        array
      end

      def to_csv
        array = []
        self.class.specification.each do |spec|
          array << Collmex::Api.stringify(@hash[spec[:name]], spec[:type])
        end
        CSV.generate_line(array, Collmex.csv_opts)
      end

      def to_h
        @hash
      end


      def to_s
        self.to_csv
      end
    end



    class Login < Line

      def initialize( opts = {:username => "", :password => ""})
        self.opts = opts
      end

      def to_a
        ["LOGIN", opts[:username], opts[:password]]
      end
    end

    class CustomerGet < Line
      def initialize( opts = {:customer_id => nil } )
        self.opts = opts
      end
      def to_a
        ["CUSTOMER_GET", opts[:customer_id], 1]
      end
    end

    class AccdocGet < Line
      def initialize( opts = {:accdoc_id => nil } )
        self.opts = opts
      end
      def to_a
        ["ACCDOC_GET", 1, nil, opts[:accdoc_id] ]
      end
    end


  end
end

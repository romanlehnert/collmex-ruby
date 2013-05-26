require "csv"

module Collmex::Api

  # Check if a given object is a Collmex::Api object
  def self.is_a_collmex_api_line_obj? obj
    obj.class.name =~ /Collmex\:\:Api/
  end

  # Check if a Line class exists for the given class name
  def self.line_class_exists?(class_name)
    klass = Collmex::Api.const_get(class_name)
    return klass.is_a?(Class)
  rescue NameError
    return false
  end

  # Parse a line given as a string or array and return
  # a Collmex::Api::Xyz object for it that inherits
  # from Collmex::Api::Line
  def self.parse_line(line)
    # in case the line is already an array
    if line.is_a?(Array) && line.first.is_a?(String) || line.is_a?(String) && line = CSV.parse_line(line, Collmex.csv_opts)
      identifyer = line.first.split(/_|-/).map { |s| s.downcase.capitalize }.join
      if self.line_class_exists?(identifyer)
        Collmex::Api.const_get(identifyer).new(line)
      else
        raise "Could not find a Collmex::Api::Line class for \"#{identifyer}\" (\"#{line.first}\")"
      end
    else
      raise "Could not parse the given line"
    end
  end

  # Given a field's content, we parse it here and return
  # a typecasted object
  def self.parse_field(value, type, opts = nil)
    case type
      when :string    then value.to_s
      when :date      then Date.parse(value.to_s) unless value.nil?
      when :int       then value.to_i unless value.nil?
      when :integer   then value.to_i unless value.nil?
      when :float     then value.to_s.gsub(',','.').to_f unless value.nil?
      when :currency  then Collmex::Api.parse_currency(value) unless value.nil?
    end
  end

  # Given a string we want to handle as currency, we parse it to get
  # the Euro-cents as integer.
  def self.parse_currency(str)
    str = str.to_s
    case str
      when /\A-?\d*[\,|.]\d{0,2}\z/ then (str.gsub(',','.').to_f * 100).to_i
      when /\A-?\d+\z/ then str.to_i
      when /\A-?((\d){1,3})*([\.]\d{3})+([,]\d{2})\z/ then (str.gsub('.','').gsub(',','.').to_f * 100).to_i
      when /\A-?((\d){1,3})*([\,]\d{3})+([.]\d{2})\z/ then (str.gsub(',','').to_f * 100).to_i
      when /\A-?((\d){1,3})*([\.\,]\d{3})+\z/ then str.gsub(',','').gsub('.','').to_i * 100
      else str.to_i
    end
  end

  # given an object, convert it to a string according to the collmex api. 
  def self.stringify(data, type)
    return "" if data.nil?
    case type
      when :integer  then data.to_i.to_s
      when :string   then data
      when :float    then sprintf("%.2f", data).gsub('.', ',')
      when :currency then stringify_currency(data)
      when :date     then data.strftime("%Y%m%d")
    end
  end

  # given an object we want to treat as currency, convert it to a string
  def self.stringify_currency(data)
    case
    when data.is_a?(Integer) then sprintf("%.2f",(data.to_f / 100)).gsub('.',',')
    when data.is_a?(Float) then sprintf("%.2f",(data.to_f)).gsub('.',',')
    when data.is_a?(String)
      int = self.parse_currency(data)
      sprintf("%.2f",(int.to_f / 100)).gsub('.',',')
    else data
    end
  end
end

require "collmex/api/line"
require "collmex/api/login"
require "collmex/api/cmxknd"
require "collmex/api/message"
require "collmex/api/customer_get"
require "collmex/api/accdoc_get"
require "collmex/api/accdoc"
require "collmex/api/cmxord2"
require "collmex/api/sales_order_get"
require "collmex/api/accbal_get"
require "collmex/api/accbal"


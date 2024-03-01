class Collmex::Api::Line

  # Holds the specification of the line object
  def self.specification
    {}
  end

  # Return an empty default-hash of the line.
  def self.default_hash
    hash = {}
    self.specification.each_with_index do |field_spec, index|
      if field_spec.has_key? :fix
        hash[field_spec[:name]] = field_spec[:fix]
      elsif field_spec.has_key? :default
        hash[field_spec[:name]] = field_spec[:default]
      else
        hash[field_spec[:name]] = Collmex::Api.parse_field(nil, field_spec[:type])
      end
    end
    hash
  end

  # returns a hash of the line that inherits from the default_hash but gets
  # filled with its contents.
  def self.hashify(data)
    hash = self.default_hash
    fields_spec = self.specification

    if data.is_a?(Array) || data.is_a?(String) && data = CSV.parse_line(data, **Collmex.csv_opts)
      fields_spec.each_with_index do |field_spec, index|
        if !data[index].nil? && !field_spec.has_key?(:fix)
          hash[field_spec[:name]] = Collmex::Api.parse_field(data[index], field_spec[:type])
        end
      end
    elsif data.is_a? Hash 
      fields_spec.each_with_index do |field_spec, index|
        if data.key?(field_spec[:name]) && !field_spec.has_key?(:fix)
          hash[field_spec[:name]] = Collmex::Api.parse_field(data[field_spec[:name]], field_spec[:type])
        end
      end
    end
    hash
  end


  def initialize(arg = nil)
    @hash = self.class.default_hash
    @hash = @hash.merge(self.class.hashify(arg)) if !arg.nil?
    if self.class.specification.empty? && self.class.name.to_s != "Collmex::Api::Line"
      raise "#{self.class.name} has no specification"
    end
  end


  def to_a
    array = []
    self.class.specification.each do |spec|
      array << @hash[spec[:name]]
    end
    array
  end

  def to_stringified_array
    array = []
    self.class.specification.each do |spec|
      array << Collmex::Api.stringify(@hash[spec[:name]], spec[:type])
    end
    array
  end


  def to_csv
    CSV.generate_line(self.to_stringified_array, **Collmex.csv_opts)
  end

  def to_h
    @hash
  end


end


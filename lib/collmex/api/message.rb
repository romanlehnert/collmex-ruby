class Collmex::Api::Message < Collmex::Api::Line
  def self.specification
    [
      { name: :identifyer       , type: :string    , fix: "MESSAGE"         },
      { name: :type             , type: :string                             },
      { name: :id               , type: :integer                            },
      { name: :text             , type: :string                             },
      { name: :line             , type: :integer                            },
    ]
  end


  def success?
    if @hash.has_key?(:type) && !@hash[:type].empty? && @hash[:type] == "S"
      true
    else
      false
    end
  end

  def result
    if @hash.has_key?(:type) && !@hash[:type].empty?
      case @hash[:type]
      when "S" then :success
      when "W" then :warning
      when "E" then :error
      else :undefined
      end
    else
      :undefined
    end
  end
end


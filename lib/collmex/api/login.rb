class Collmex::Api::Login < Collmex::Api::Line
  def self.specification
    [
      { name: :identifyer,    type: :string,    fix: "LOGIN"   },
      { name: :username,      type: :string },
      { name: :password,      type: :string }
    ]
  end
end

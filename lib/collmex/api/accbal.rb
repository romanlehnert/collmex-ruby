class Collmex::Api::AccBal < Collmex::Api::Line
  def self.specification
    [
      {name: :identifyer,      type: :string, fix: "ACC_BAL"},
      {name: :account_number,  type: :integer},
      {name: :account_name,    type: :string},
      {name: :account_balance, type: :currency}
    ]
  end
end


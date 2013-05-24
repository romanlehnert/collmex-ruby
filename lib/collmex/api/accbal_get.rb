class Collmex::Api::AccbalGet < Collmex::Api::Line
  def self.specification
    [
      {name: :identifyer,     type: :string, fix: "ACCBAL_GET"},
      {name: :company_id,     type: :integer, default: 1},
      {name: :fiscal_year,    type: :integer, default: Date.today.year},
      {name: :date_to,        type: :date},
      {name: :account_number, type: :integer},
      {name: :account_group,  type: :integer}
    ]
  end
end


